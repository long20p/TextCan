import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ConfigService } from './config.service';

interface ContentData {
  text: string;
}

@Injectable({
  providedIn: 'root'
})
export class ContentService {

  constructor(private httpClient: HttpClient, private configService: ConfigService) { }

  createContent(data: ContentData): Observable<string> {
    return this.httpClient.post<string>(this.configService.Values.baseUrl + 'api/content/create', data, { responseType: 'text' as 'json' });
  }

  getContent(key: string): Observable<string> {
    return this.httpClient.get<string>(this.configService.Values.baseUrl + 'api/content/get/' + key, { responseType: 'text' as 'json' });
  }
}
