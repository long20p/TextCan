import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { contentService } from '../services/content.service';

const ReadOnlyComponent: React.FC = () => {
  const [contentText, setContentText] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { uniqueKey } = useParams<{ uniqueKey: string }>();

  useEffect(() => {
    const loadContent = async () => {
      if (!uniqueKey) {
        setError('No key provided');
        setIsLoading(false);
        return;
      }

      try {
        setIsLoading(true);
        const content = await contentService.getContent(uniqueKey);
        setContentText(content);
        setError(null);
      } catch (err) {
        console.error('Error loading content:', err);
        setError('Failed to load content');
        setContentText('');
      } finally {
        setIsLoading(false);
      }
    };

    loadContent();
  }, [uniqueKey]);

  if (isLoading) {
    return (
      <div className="main-content">
        <div className="text-center">Loading...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="main-content">
        <div className="alert alert-danger">{error}</div>
      </div>
    );
  }

  return (
    <div className="main-content">
      <textarea
        className="form-control"
        rows={20}
        value={contentText}
        readOnly
      />
    </div>
  );
};

export default ReadOnlyComponent;
