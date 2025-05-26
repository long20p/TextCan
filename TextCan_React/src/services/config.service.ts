export interface ConfigValues {
  baseUrl: string;
  [key: string]: any;
}

class ConfigService {
  private values: ConfigValues = { baseUrl: '' };

  get Values(): ConfigValues {
    return this.values;
  }

  async load(): Promise<boolean> {
    try {
      const response = await fetch('/assets/settings.json');
      if (!response.ok) {
        throw new Error(`Failed to load config: ${response.statusText}`);
      }
      this.values = await response.json();
      return true;
    } catch (error) {
      console.error('Failed to load configuration', error);
      throw error;
    }
  }
}

export const configService = new ConfigService();
