import { Component, OnInit } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ContentService } from './services/content.service'

@Component({
  selector: 'app-main',
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.scss']
})
export class MainComponent implements OnInit {

  constructor(private formBuilder: FormBuilder, 
              private contentService: ContentService,
              private route: ActivatedRoute,
              private router: Router) { }

  contentForm = this.formBuilder.group({
    text: ['']
  });

  ngOnInit() {
  }

  onSubmit() {
    console.log(this.contentForm.value);
    this.contentService.createContent(this.contentForm.value).subscribe({
      next: key => {
        console.log(key);
        this.router.navigate([key]);
      },
      error: message => console.error(message)
    })
  }

}
