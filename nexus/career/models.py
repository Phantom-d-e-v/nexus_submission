from django.db import models
from django.contrib.auth.models import User

class SelectedCareer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    career_name = models.CharField(max_length=255, null=True)
    description = models.TextField(null=True)
    skills_required = models.JSONField(null=True)  # List of skills required for the career

    def __str__(self):
        return f"{self.user.username} - {self.career_name}"

class Course(models.Model):
    career = models.ForeignKey(SelectedCareer, on_delete=models.CASCADE, related_name='courses', null=True)
    title = models.CharField(max_length=255, null=True)
    description = models.TextField(null=True)
    link = models.URLField(null=True)

    def __str__(self):
        return self.title


class JobPortal(models.Model):
    career = models.ForeignKey(SelectedCareer, on_delete=models.CASCADE, related_name='job_portals', null=True)
    title = models.CharField(max_length=255, null=True)
    description = models.TextField(null=True)
    link = models.URLField(null=True)

    def __str__(self):
        return self.title
