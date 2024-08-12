from rest_framework.response import Response
from rest_framework import generics

from assessment.models import UserPreferences
from gemini_api import generate_career_details, generate_course_recommendations, generate_cv_suggestions, generate_job_portal_recommendations
from .models import Course, JobPortal, SelectedCareer
from .serializers import CareerProgressSerializer, CourseSerializer, JobPortalSerializer, SelectedCareerSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from rest_framework.views import APIView

class SaveSelectedCareerView(APIView):
    @permission_classes([IsAuthenticated])

    def post(self, request, *args, **kwargs):
        user = request.user
        career_name = request.data.get('career_name')

        try:
            career_details = generate_career_details(career_name)
            description = career_details.get('description')
            skills_required = career_details.get('skills_required')
        except Exception as e:
            return Response({'error': str(e)}, status=500)

        selected_career, created = SelectedCareer.objects.update_or_create(
            user=user,
            defaults={
                'career_name': career_name,
                'description': description,
                'skills_required': skills_required
            }
        )
        return Response({'status': 'career selected'})

class FetchSelectedCareerView(APIView):
    @permission_classes([IsAuthenticated])

    def get(self, request, *args, **kwargs):
        user = request.user
        selected_career = SelectedCareer.objects.get(user=user)
        serializer = SelectedCareerSerializer(selected_career)
        return Response(serializer.data)
    
class AddCourseView(APIView):
    @permission_classes([IsAuthenticated])
    def post(self, request, *args, **kwargs):
        user = request.user
        career_name = request.data.get('career_name')
        course_data = request.data.get('course')

        selected_career, created = SelectedCareer.objects.get_or_create(
            user=user,
            career_name=career_name
        )

        Course.objects.create(
            career=selected_career,
            title=course_data.get('title'),
            description=course_data.get('description', ''),
            link=course_data.get('link')
        )

        return Response({'status': 'course added'})

class AddJobPortalView(APIView):
    @permission_classes([IsAuthenticated])
    def post(self, request, *args, **kwargs):
        user = request.user
        career_name = request.data.get('career_name')
        job_portal_data = request.data.get('job_portal')

        selected_career, created = SelectedCareer.objects.get_or_create(
            user=user,
            career_name=career_name
        )

        JobPortal.objects.create(
            career=selected_career,
            title=job_portal_data.get('title'),
            description=job_portal_data.get('description', ''),
            link=job_portal_data.get('link')
        )

        return Response({'status': 'job portal added'})
class GetCourseRecommendations(APIView):
    @permission_classes([IsAuthenticated])
    def post(self, request):
        user = request.user
        try:
            user_preferences = UserPreferences.objects.get(user=user)
            selected_career = SelectedCareer.objects.get(user=user)
            preferences_data = {
                'interests': user_preferences.interests,
                'skills': user_preferences.skills,
                'career': selected_career
            }  
            recommendations = generate_course_recommendations(preferences_data)
            print(recommendations)
            return Response(recommendations)
        except UserPreferences.DoesNotExist:
            return Response({'error': 'User preferences not found.'})
        except Exception as e:
            return Response({'error': str(e)})

class GetJobPortalRecommendations(APIView):
    @permission_classes([IsAuthenticated])
    def post(self, request):
        user = request.user
        try:      
            user_preferences = UserPreferences.objects.get(user=user)
            career_name = SelectedCareer.objects.get(user=user)
            skills_required = user_preferences.skills  # Or extract from request if needed

            recommendations = generate_job_portal_recommendations(career_name, skills_required)
            return Response(recommendations)
        except UserPreferences.DoesNotExist:
            return Response({'error': 'User preferences not found.'})
        except Exception as e:
            return Response({'error': str(e)})

class EnhanceCVView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        cv_text = request.data.get('cv_text')
        skills = UserPreferences.objects.get(user=user)
        career_name = SelectedCareer.objects.get(user=user)

        try:
            suggestions = generate_cv_suggestions(cv_text, career_name, skills)
            return Response({'suggestions': suggestions})
        except Exception as e:
            return Response({'error': str(e)}, status=500)