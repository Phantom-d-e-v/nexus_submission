from django.urls import path
from. import views
from .views import GetAssessmentQuestions, GetCareerRecommendations, SubmitAssessment

urlpatterns = [
    path('submit-preferences/', views.submit_preferences, name='submit_preferences'),
    path('get-assessment-questions/', GetAssessmentQuestions.as_view(), name='get_assessment_questions'),
    path('submit-assessment/', SubmitAssessment.as_view(), name='submit_assessment'),
    path('get-career-recommendations/', GetCareerRecommendations.as_view(), name='get-career-recommendations'),
]