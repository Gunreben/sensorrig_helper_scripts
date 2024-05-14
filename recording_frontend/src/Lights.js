import React, { useState } from 'react';

function Lights() {
  const [lightsState, setLightsState] = useState(new Array(8).fill(false));

  const handleLightControl = async (channel) => {
    const newState = !lightsState[channel];
    const response = await fetch('http://192.168.26.4:5000/control_light', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ channel, state: newState ? 'on' : 'off' }),
    });

    if (!response.ok) {
      alert(`Failed to toggle light on channel ${channel}`);
    } else {
      let newStates = [...lightsState];
      newStates[channel] = newState;
      setLightsState(newStates);
    }
  };

  const renderButtons = () => {
    return lightsState.map((state, channel) => (
      <div key={channel} className={`channel-control channel-${channel}`}>
        <button className={`button ${state ? 'off' : 'on'}`} onClick={() => handleLightControl(channel)}>
          {state ? 'OFF' : 'ON'}
        </button>
      </div>
    ));
  };

  return (
    <div className="lights">
      <h2>Lights Control</h2>
      <div className="controls octagon">{renderButtons()}</div>
    </div>
  );
}

export default Lights;
