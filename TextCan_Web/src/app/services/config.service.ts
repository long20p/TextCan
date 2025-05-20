import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment';
import { firstValueFrom } from 'rxjs';

export interface ConfigValues {
  baseUrl: string;
  [key: string]: any;
}

@Injectable({
  providedIn: 'root'
})
export class ConfigService {

  constructor(private httpClient: HttpClient) { }

  private values: ConfigValues = { baseUrl: '' };

  get Values(): ConfigValues {
    return this.values;
  }

  load(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      this.httpClient.get<ConfigValues>(environment.configFileLocation).subscribe({
        next: (response) => {
          this.values = response;
          resolve(true);
        },
        error: (error) => {
          console.error('Failed to load configuration', error);
          reject(error);
        }
      });
    });
  }
}
