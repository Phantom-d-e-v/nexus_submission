from django.urls import path
from .views import AddCourseView, AddJobPortalView, EnhanceCVView, FetchSelectedCareerView, GetCourseRecommendations, GetJobPortalRecommendations, SaveSelectedCareerView

urlpatterns = [
    path('select-career/', SaveSelectedCareerView.as_view(), name='select-career'),
    path('fetch-career/', FetchSelectedCareerView.as_view(), name='fetch-career'),\
    path('add-course/', AddCourseView.as_view(), name='add-course'),
    path('add-job-portal/', AddJobPortalView.as_view(), name='add-job-portal'),
    path('get-course-recommendations/', GetCourseRecommendations.as_view(), name='get-course-recommendations'),
    path('get-job-portal-recommendations/', GetJobPortalRecommendations.as_view(), name='get-job-portal-recommendations'),
    path('enhance-cv/', EnhanceCVView.as_view(), name='enhance-cv')
]
