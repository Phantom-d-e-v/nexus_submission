from rest_framework import serializers
from .models import Assessment, AssessmentQuestion, CareerRecommendation, UserAnswer, UserPreferences 

class UserPreferencesSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserPreferences
        fields = ['interests', 'skills']

class AssessmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Assessment
        fields = ['id', 'user', 'results', 'created_at']

class AssessmentQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = AssessmentQuestion
        fields =  '__all__'

class UserAnswerSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserAnswer
        fields = ['id', 'user', 'question', 'selected_option', 'created_at']

class CareerRecommendationSerializer(serializers.ModelSerializer):
    class Meta:
        model = CareerRecommendation
        fields = '__all__'
