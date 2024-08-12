from django.db import models

class CareerCategory(models.Model):
    name = models.CharField(max_length=100)

class Career(models.Model):
    category = models.ForeignKey(CareerCategory, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    description = models.TextField()

class UserCareerPreference(models.Model):
    user = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    career = models.ForeignKey(Career, on_delete=models.CASCADE)
    score = models.FloatField()
