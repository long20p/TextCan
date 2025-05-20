import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ContentService } from './services/content.service';

@Component({
  selector: 'app-read-only',
  templateUrl: './read-only.component.html',
  styleUrls: ['./read-only.component.scss']
})
export class ReadOnlyComponent implements OnInit {

  contentText: string = '';

  constructor(private route: ActivatedRoute, private contentService: ContentService) { }

  ngOnInit(): void {
    const key = this.route.snapshot.paramMap.get('uniqueKey');
    if (key) {
      this.contentService.getContent(key).subscribe({
        next: (content: string) => this.contentText = content,
        error: (message: any) => console.error(message)
      });
    }
  }

}
