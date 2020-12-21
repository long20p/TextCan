import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment'

@Injectable({
  providedIn: 'root'
})
export class ContentService {

  constructor(private httpClient: HttpClient) { }

  createContent(data): Observable<string> {
    return this.httpClient.post(environment.baseUrl + 'api/content/create', data, { responseType: 'text' });
  }

  getContent(key: string): Observable<string> {
    return this.httpClient.get(environment.baseUrl + 'api/content/get/' + key, { responseType: 'text' });
  }
}
