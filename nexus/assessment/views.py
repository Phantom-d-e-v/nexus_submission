import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
from .models import Assessment, AssessmentQuestion, CareerRecommendation, UserAnswer, UserPreferences
from .serializers import AssessmentQuestionSerializer, CareerRecommendationSerializer, UserPreferencesSerializer
from gemini_api import analyze_and_recommend, generate_assessment_questions
from rest_framework.parsers import JSONParser

import logging

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def submit_preferences(request):
    try:
     
        data = json.loads(request.body.decode('utf-8'))

        serializer = UserPreferencesSerializer(data=data)

        if serializer.is_valid():

            preferences, created = UserPreferences.objects.update_or_create(
                        user=request.user,
                        defaults=serializer.validated_data
            )
         
            return JsonResponse({"message": "Preferences saved successfully"}, status=200)
        else:
            return JsonResponse(serializer.errors, status=400)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except Exception as e:
        return JsonResponse({'error': 'An error occurred during processing'}, status=401)


class GetAssessmentQuestions(APIView):
    @permission_classes([IsAuthenticated])
    def get(self, request):
        user = request.user

        try:
            user_preferences = UserPreferences.objects.get(user=user)
        except UserPreferences.DoesNotExist:
            return Response({"error": "User preferences not found"}, status=status.HTTP_404_NOT_FOUND)
        
        preferences_data = {
            "interests": user_preferences.interests,
            "skills": user_preferences.skills,
        }

        questions = generate_assessment_questions(preferences_data)

        return Response(questions, status=status.HTTP_200_OK)


class SubmitAssessment(APIView):
    @permission_classes([IsAuthenticated])
    def post(self, request):
        user = request.user
        print(f'Content-Type: {request.content_type}')
        print(f'Request Body: {request.body.decode("utf-8")}')

        try:
            data = request.data.get('answers', [])
        except Exception as e:
            return Response({"error": f"Error processing request: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)

        if not data:
            return Response({"error": "No answers provided"}, status=status.HTTP_400_BAD_REQUEST)

        answers_data = []
        for item in data:
            question_data = item.get('question', {})
            question_text = question_data.get('question_text', '')
            answer = item.get('answer', '')

            if question_text and answer:
                answers_data.append({"question": question_text, "answer": answer})

        recommendations = analyze_and_recommend(answers_data)

        recommendation_obj = CareerRecommendation.objects.create(
            user=user,
            recommendation=recommendations
        )

        return Response({"message": "Assessment submitted and recommendations saved successfully."}, status=status.HTTP_200_OK)


class GetCareerRecommendations(APIView):
    @permission_classes([IsAuthenticated])
    def get(self, request):
        user = request.user

        try:

            recommendation_obj = CareerRecommendation.objects.filter(user=user).latest('created_at')
        except CareerRecommendation.DoesNotExist:
            return Response({"error": "No career recommendations found for this user."}, status=status.HTTP_404_NOT_FOUND)

        serializer = CareerRecommendationSerializer(recommendation_obj)
        return Response(serializer.data, status=status.HTTP_200_OK)
