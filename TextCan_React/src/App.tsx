import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import MainComponent from './components/MainComponent';
import ReadOnlyComponent from './components/ReadOnlyComponent';
import { configService } from './services/config.service';

const App: React.FC = () => {
  const [isConfigLoaded, setIsConfigLoaded] = useState(false);
  const [configError, setConfigError] = useState<string | null>(null);

  useEffect(() => {
    const loadConfig = async () => {
      try {
        await configService.load();
        setIsConfigLoaded(true);
      } catch (error) {
        console.error('Failed to load configuration:', error);
        setConfigError('Failed to load application configuration');
      }
    };

    loadConfig();
  }, []);

  if (configError) {
    return (
      <div className="container mt-4">
        <div className="alert alert-danger">
          {configError}
        </div>
      </div>
    );
  }

  if (!isConfigLoaded) {
    return (
      <div className="container mt-4">
        <div className="text-center">
          <div className="spinner-border" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
          <p className="mt-2">Loading application...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="app-background min-vh-100 py-4">
      <div className="container">
        <Router>
          <Routes>
            <Route path="/" element={<MainComponent />} />
            <Route path="/:uniqueKey" element={<ReadOnlyComponent />} />
          </Routes>
        </Router>
      </div>
    </div>
  );
};

export default App;
