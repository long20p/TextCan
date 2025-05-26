import { configService } from './config.service';

export interface ContentData {
  text: string;
}

class ContentService {
  async createContent(data: ContentData): Promise<string> {
    const response = await fetch(
      `${configService.Values.baseUrl}api/content/create`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'text/plain',
          'X-Requested-With': 'XMLHttpRequest'
        },
        body: JSON.stringify(data),
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to create content: ${response.statusText}`);
    }

    return await response.text();
  }

  async getContent(key: string): Promise<string> {
    const response = await fetch(
      `${configService.Values.baseUrl}api/content/get/${key}`,
      {
        headers: {
          'Accept': 'text/plain',
          'X-Requested-With': 'XMLHttpRequest'
        }
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to get content: ${response.statusText}`);
    }

    return await response.text();
  }
}

export const contentService = new ContentService();
