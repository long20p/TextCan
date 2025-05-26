import React, { useState, FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { contentService, ContentData } from '../services/content.service';

const MainComponent: React.FC = () => {
  const [text, setText] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    
    if (!text.trim()) {
      return;
    }

    setIsLoading(true);
    
    try {
      const contentData: ContentData = { text };
      const key = await contentService.createContent(contentData);
      console.log('Content created with key:', key);
      navigate(`/${key}`);
    } catch (error) {
      console.error('Error creating content:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="main-content">
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <textarea
            className="form-control"
            rows={20}
            placeholder="Put your text here"
            value={text}
            onChange={(e) => setText(e.target.value)}
            required
          />
        </div>
        <button
          type="submit"
          className="btn btn-info btn-round btn-lg submitBtn"
          disabled={!text.trim() || isLoading}
        >
          {isLoading ? 'Creating...' : 'Create'}
        </button>
      </form>
    </div>
  );
};

export default MainComponent;
