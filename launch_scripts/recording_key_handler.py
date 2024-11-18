from pynput import keyboard
import subprocess
import datetime

def exec_in_docker(command):
    """
    Executes a command inside the Docker container, ensuring ROS 2 environment is sourced.
    Additionally, redirects the command's output to null (or a log file) to prevent interference with keyboard input handling.
    """
    docker_command = [
        "docker", "exec", "-i", "isaac_ros_dev-aarch64-container", "/bin/bash", "-c",
        f"source /opt/ros/humble/setup.bash && cd /data && {command}"
    ]
    
    current_date = datetime.datetime.now().strftime('%Y-%m-%d')
    logfile_name = f'rosbag2_record_logs_{current_date}.txt'
    
    with open('/mnt/data/' + logfile_name, 'a') as logfile:
    	subprocess.run(docker_command, stdout=logfile, stderr=logfile, check=True)

def stop_ros2_bag_recording():
    """
    Stops the ROS 2 bag recording by sending a SIGINT signal to the process.
    """
    stop_command = "pkill -2 -f 'ros2 bag record'"
    docker_command = [
        "docker", "exec", "-i", "isaac_ros_dev-aarch64-container", "/bin/bash", "-c",
        f"source /opt/ros/humble/setup.bash &&  {stop_command} "
    ]
    
    current_date = datetime.datetime.now().strftime('%Y-%m-%d')
    logfile_name = f'rosbag2_record_logs_{current_date}.txt'
    
    with open('/mnt/data/' + logfile_name, 'a') as logfile:
    	subprocess.run(docker_command, stdout=logfile, stderr=logfile, check=True)


def on_press(key):
    try:
        if key == keyboard.Key.f1:
            # Start recording
            print('ros2 bag record started')
            exec_in_docker("ros2 bag record -a")
        elif key == keyboard.Key.f2:
            # Pause recording (ROS 2 Galactic and newer)
            exec_in_docker("ros2 bag pause")
            print('ros2 bag recording paused')
        elif key == keyboard.Key.f3:
            # Stop recording
            print('ros2 bag recording stopped')
            stop_ros2_bag_recording()
    except AttributeError:
        pass

listener = keyboard.Listener(on_press=on_press)
listener.start()
listener.join()

