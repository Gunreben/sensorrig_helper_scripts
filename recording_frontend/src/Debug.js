import React, { useState, useEffect } from 'react';

function Debug() {
  const [topics, setTopics] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [echoData, setEchoData] = useState('');
  const [showModal, setShowModal] = useState(false);

  useEffect(() => {
    fetchTopics();
  }, []);

  const fetchTopics = () => {
    setLoading(true);
    fetch('http://192.168.26.4:5000/ros/topics')
      .then(res => res.json())
      .then(data => {
        if (data.error) {
          setError(data.error);
        } else {
          setTopics(data);
        }
        setLoading(false);
      })
      .catch(err => {
        setError('Failed to fetch ROS topics.');
        setLoading(false);
      });
  };

  const handleTopicClick = (topic) => {
    fetch('http://192.168.26.4:5000/ros/echo', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ topic })
    })
    .then(res => res.json())
    .then(data => {
      if (data.error) {
        setError(data.error);
      } else {
        setEchoData(data.data);
        setShowModal(true);
      }
    })
    .catch(() => {
      setError('Failed to fetch data from topic.');
    });
  };

  return (
    <div className="debug">
      <h1>Available ROS Topics:</h1>
      {loading ? (
        <p>Loading topics...</p>
      ) : error ? (
        <p>Error: {error}</p>
      ) : (
        <div>
          {topics.map((topic, index) => (
            <button key={index} onClick={() => handleTopicClick(topic)}>
              {topic}
            </button>
          ))}
        </div>
      )}
      {showModal && (
        <div className="modal" onClick={() => setShowModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>{`Data from ${topics[0]}`}</h2>
            <pre>{echoData}</pre>
          </div>
        </div>
      )}
    </div>
  );
}

export default Debug;
