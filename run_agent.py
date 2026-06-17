import os
from google import genai
from google.genai import types
from dotenv import load_dotenv

# Load the environment variables from the .env file
load_dotenv() 

# Initialize the Gemini Client
client = genai.Client()

def read_file(filepath):
    """Reads standard text/markdown files"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return f.read()

def main():
    print("Loading Agent Profile and Skills...")
    agent_profile = read_file("AGENTS.md")
    agent_skills = read_file(".opencode/skills/db-design-pipeline/SKILL.md")
    
    print("Reading business-requirement.md...")
    # Update the target file name here
    target_file = "req/business-requirement.md"
    
    if not os.path.exists(target_file):
        print(f"Error: Please place '{target_file}' in this directory.")
        return
        
    # We can now use the standard read_file function instead of a PDF reader
    project_requirements = read_file(target_file)

    # Combine profile and skills into the System Instruction
    system_instruction = f"""
    {agent_profile}
    
    Here are your specific instructions and execution skills:
    {agent_skills}
    """

    # List of deliverables to generate sequentially
    deliverables = [
        {"file": "outputs/01-business-req-analysis-G11.md", "prompt": "Execute Skill 1: Business Requirement Analysis. Analyze the project requirements text and output the markdown file structure."},
        {"file": "outputs/02-erd-design-G11.md", "prompt": "Execute Skill 2: Conceptual Database Design. Based on the previous analysis, output the ERD design markdown file using text/Mermaid syntax."},
        {"file": "outputs/03-logical-design-G11.md", "prompt": "Execute Skill 3: Logical Database Design. Convert the design into a logical relational schema markdown file."},
        {"file": "outputs/04-design-validation-G11.md", "prompt": "Execute Skill 4: Database Design Validation. Review the logical schema against rules and output the validation report."},
        {"file": "outputs/05-db-definition-G11.sql", "prompt": "Execute Skill 5: Database Implementation (DDL). Write the clean SQL DDL script."},
        {"file": "outputs/06-sample-data-G11.sql", "prompt": "Execute Skill 6: Sample Data Preparation. Generate the SQL script containing realistic INSERT statements."},
        {"file": "outputs/07-query-design-G11.sql", "prompt": "Execute Skill 7: Query Design. Generate the 5 business queries with their required metadata descriptions."}
    ]

    # Use gemini-2.5-flash as it excels at structured instructions and long context
    model_name = "gemini-2.5-flash"

    print("\nStarting Agent Core Execution...\n")
    
    for task in deliverables:
        print(f" Generating: {task['file']}...")
        
        user_content = f"""
        Project Context Requirements:
        {project_requirements}
        
        Task:
        {task['prompt']}
        
        Provide only the clean file content without any extra conversational filler text outside the markdown/SQL wrapper.
        """

        response = client.models.generate_content(
            model=model_name,
            contents=user_content,
            config=types.GenerateContentConfig(
                system_instruction=system_instruction,
                temperature=0.2, # Lower temperature makes the agent more predictable and precise
            )
        )

        # Ensure outputs directory exists
        os.makedirs(os.path.dirname(task['file']), exist_ok=True)
        
        # Save output
        with open(task['file'], 'w', encoding='utf-8') as out_file:
            out_file.write(response.text)
            
        print(f"Saved to {task['file']}\n")

if __name__ == "__main__":
    main()