import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ContentService } from './services/content.service';

interface ContentForm {
  text: string;
}

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

  contentForm: FormGroup = this.formBuilder.group({
    text: ['']
  });

  ngOnInit(): void {
  }

  onSubmit(): void {
    const formValue = this.contentForm.value as ContentForm;
    console.log(formValue);
    this.contentService.createContent(formValue).subscribe({
      next: (key: string) => {
        console.log(key);
        this.router.navigate([key]);
      },
      error: (message: any) => console.error(message)
    });
  }

}
