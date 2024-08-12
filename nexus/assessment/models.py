from django.db import models
from django.contrib.auth.models import User
    
class UserPreferences(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    interests = models.JSONField() 
    skills = models.JSONField() 

    def __str__(self):
        return f"Preferences for {self.user.username}"

class Assessment(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    results = models.JSONField()  
    created_at = models.DateTimeField(auto_now_add=True)

class AssessmentQuestion(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=1)
    question_text = models.TextField()
    question_type = models.CharField(max_length=50, null=True, blank=True)  # e.g., "multiple_choice", "short_answer"
    options = models.JSONField(null=True, blank=True)  # For multiple choice questions

    def __str__(self):
        return self.question_text

class UserAnswer(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, default=1)
    question = models.ForeignKey(AssessmentQuestion, on_delete=models.CASCADE)
    answer = models.CharField(max_length=1000, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

class CareerRecommendation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    recommendation = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
