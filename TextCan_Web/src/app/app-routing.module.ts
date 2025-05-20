import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { MainComponent } from './main.component';
import { ReadOnlyComponent } from './read-only.component';

const routes: Routes = [
  { path: '', component: MainComponent },
  { path:':uniqueKey', component: ReadOnlyComponent }
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { relativeLinkResolution: 'legacy' })],
  exports: [RouterModule]
})
export class AppRoutingModule { }
