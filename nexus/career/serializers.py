from rest_framework import serializers
from .models import Course, JobPortal, SelectedCareer

class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Course
        fields = '__all__'

class JobPortalSerializer(serializers.ModelSerializer):
    class Meta:
        model = JobPortal
        fields = '__all__'


class CareerProgressSerializer(serializers.ModelSerializer):
    courses = CourseSerializer(many=True, read_only=True)
    job_portals = JobPortalSerializer(many=True, read_only=True)

    class Meta:
        model = SelectedCareer
        fields = '__all__'
        
class SelectedCareerSerializer(serializers.ModelSerializer):
    courses = CourseSerializer(many=True, read_only=True)
    job_portals = JobPortalSerializer(many=True, read_only=True)

    class Meta:
        model = SelectedCareer
        fields = '__all__'
