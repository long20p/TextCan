import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment'

@Injectable({
  providedIn: 'root'
})
export class ConfigService {

  constructor(private httpClient: HttpClient) { }

  private values: any;

  get Values() {
    return this.values;
  }

  load(): Promise<any> {
    return new Promise((resolve, reject) => {
      this.httpClient.get(environment.configFileLocation).subscribe(response =>
        {
          this.values = response;
          resolve(true);
        })
    });
  }
}
