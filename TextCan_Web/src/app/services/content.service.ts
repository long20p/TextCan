import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ConfigService } from './config.service'

@Injectable({
  providedIn: 'root'
})
export class ContentService {

  constructor(private httpClient: HttpClient, private configService: ConfigService) { }

  createContent(data): Observable<string> {
    return this.httpClient.post(this.configService.Values.baseUrl + 'api/content/create', data, { responseType: 'text' });
  }

  getContent(key: string): Observable<string> {
    return this.httpClient.get(this.configService.Values.baseUrl + 'api/content/get/' + key, { responseType: 'text' });
  }
}
