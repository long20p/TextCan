import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ContentService } from './services/content.service';

@Component({
  selector: 'app-read-only',
  templateUrl: './read-only.component.html',
  styleUrls: ['./read-only.component.scss']
})
export class ReadOnlyComponent implements OnInit {

  contentText: string;

  constructor(private route: ActivatedRoute, private contentService: ContentService) { }

  ngOnInit() {
    var key = this.route.snapshot.paramMap.get('uniqueKey');
    this.contentService.getContent(key).subscribe({
      next: content => this.contentText = content,
      error: message => console.error(message)
    })
  }

}
