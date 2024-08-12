import json
import re
import google.generativeai as genai
import os

genai.configure(api_key=os.getenv("API_KEY"))

def parse_questions(response_text):
    questions = []
    parts = response_text.split("\n\n")
    for part in parts:
        lines = part.strip().split("\n")
        
        if not lines or not lines[0].strip():
            continue  
        
        question_text = lines[0]
        if question_text.startswith("Q:"):
            question_text = question_text[2:].strip()  
            options = [line.strip().strip("*").strip() for line in lines[1:] if line.strip().startswith("*")]
            question_type = "multiple_choice"
        elif question_text.startswith("S:"):
            question_text = question_text[2:].strip()  
            options = None
            question_type = "short_answer"
        else:
            continue 

        questions.append({
            "question_text": question_text,
            "question_type": question_type,
            "options": options
        })

    return questions

def parse_recommendations(response_text):
    questions = []
    parts = response_text.split("\n\n")
    for part in parts:
    
        lines = part.strip().split("\n")

        if not lines or lines[0].strip().startswith("##") or lines[0].strip().startswith("**"):
            continue 

        question_text = lines[0]
        options = [line.strip().strip("*").strip() for line in lines[1:] if line.strip().startswith("*")]

        question_type = "multiple_choice" if options else "short_answer"

        questions.append({
            "text": question_text,
            "type": question_type,
            "options": options if question_type == "multiple_choice" else None
        })


def generate_assessment_questions(preferences_data):
    model = genai.GenerativeModel('gemini-1.5-flash')
    prompt = (
        f"Generate at least 10 assessment questions for a career decision test. "
        f"The questions should be relevant to the user's interests in {preferences_data['interests']} and skills in {preferences_data['skills']}. "
        f"Provide a mix of multiple-choice questions (starting with 'Q:') and short-answer questions (starting with 'S:'). "
        f"List all multiple-choice options under each question, starting each option with '*'. Avoid any extra text, markdown formatting, or instructions."
    )
    response = model.generate_content(prompt)
    
    try:
        print(response)
        questions = parse_questions(response.text)
        print(questions)
    except Exception as e:
        raise ValueError(f"Failed to parse questions: {response.text}") from e
    
    return questions

def analyze_and_recommend(answers):
    model = genai.GenerativeModel('gemini-1.5-flash')
    prompt = (
        f"Analyze the following assessment results:\n\n"
        f"{answers}\n\n"
        "Based on these, provide the user's strengths and recommend suitable careers. "
        "Return the response in two sections: "
        "1. User Strengths - user strengths according to the assessment. "
        "2. Recommended Careers - A list of suitable careers based on the strengths. \n\n"
        "Avoid any extra text, markdown formatting, or instructions."
    )
    response = model.generate_content(prompt)
    return response.text

def generate_career_details(career_name):
    model = genai.GenerativeModel('gemini-1.5-flash')
    prompt = (
        f"Generate a detailed description and list of required skills for a career as a {career_name}."
    )
    response = model.generate_content(prompt)
    
    try:

        description, skills_text = response.text.split("\n\n", 1)
        skills_required = [skill.strip() for skill in skills_text.split("\n") if skill.strip()]
        
        return {
            'description': description.strip(),
            'skills_required': skills_required
        }
    except Exception as e:
        raise ValueError(f"Failed to parse career details: {response.text}") from e

def generate_course_recommendations(preferences_data):
    model = genai.GenerativeModel('gemini-1.5-flash')
    prompt = (
        f"Based on the career preference of {preferences_data['career']} and skills in {preferences_data['interests']} and {preferences_data['skills']}, "
        "recommend engaging courses that would enhance these skills and align with these interests. Provide the recommendations in the following format: "
        "[{\"title\": \"Course Title\", \"description\": \"Course Description\", \"link\": \"Course Link\"}, ...]"
    )
    response = model.generate_content(prompt)
    
    try:

        courses = response.text
       
        return courses
    except json.JSONDecodeError:
        raise ValueError("The response is not a valid JSON format. Response text: {response.text}")
    except Exception as e:
        raise ValueError(f"Failed to parse course recommendations: {str(e)}") from e

def generate_job_portal_recommendations(career_name, skills_required):
    model = genai.GenerativeModel('gemini-1.5-flash')
    prompt = (
        f"For someone interested in {career_name} with skills in {skills_required}, "
        "suggest reputable job portals and links where they can find relevant opportunities. Provide the recommendations in the following format: "
        "[{\"title\": \"Portal Name\", \"description\": \"Portal Description\", \"link\": \"Portal Link\"}, ...]"
    )
    response = model.generate_content(prompt)
    
    try:

        job_portals = response.text
       
        return job_portals
    except json.JSONDecodeError:
        raise ValueError("The response is not a valid JSON format. Response text: {response.text}")
    except Exception as e:
        raise ValueError(f"Failed to parse job portal recommendations: {str(e)}") from e
    
def generate_cv_suggestions(cv_text, career_name, skills):
    model = genai.GenerativeModel('gemini-1.5-flash')
    prompt = (
        f"Review and enhance the following CV text for a career as a {career_name}. "
        f"The user's skills include {skills}. Provide detailed suggestions for improvement.\n\n"
        f"{cv_text}\n\n"
        "Return the suggestions in a clear format without any extra text or markdown formatting."
    )
    response = model.generate_content(prompt)
    
    try:
        suggestions = response.text
        return suggestions
    except Exception as e:
        raise ValueError(f"Failed to generate CV suggestions: {response.text}") from e
