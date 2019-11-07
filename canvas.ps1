#####################################################################################
#
# POWERSHELL 5.1 Sample Script to download student assignments and posting feedback 
# and grades
# Replace <something> with custom data
# Add Grader commands 
#
######################################################################################

#Initial declarations
$course = "<course_id>" #Example: $course = "1"
$assignment = "<assignment_id>" #Example: $assignment = "2"
$token = "<token_generated_from_canvas>"
$working_dir = "<local_working_directory>"
$domain = "<website domain>" # Example: $domain = "https://school.domain.com" 

$headers = @{"Authorization"="Bearer "+$token}
$submissions_url = $domain + "/api/v1/courses/"+$course+"/assignments/"+$assignment+"/submissions"
$grading_url = $domain + "/api/v1/courses/"+$course+"/assignments/"+$assignment+"/submissions/" # + student_id


# Retrieving Student information
$student_submissions = Invoke-RestMethod -Uri $submissions_url -Method GET -headers $headers

foreach ($submission in $student_submissions) {
    # Student pointers
    $student_id = $submission.user_id;

    #This will download the student file in the working directory
    Invoke-WebRequest -Uri $submission.attachments[0].url -OutFile "$($working_dir)\$($submission.attachments[0].filename)";

    # Execute the grader script on the student file
    # <The grader part here>
    
    #Example - Extract student project into a folder with same name
    # $base_name = (Get-Item "$($working_dir)\$($submission.attachments[0].filename)").BaseName;
    # Expand-Archive -Path "$($working_dir)\$($submission.attachments[0].filename)" -DestinationPath "$($working_dir)\$(base_name)";
    # Feedback and grade in two variables
    $feedback = "<Something generated from the grader script>";
    $grade = "<Something generated from the grader script>";

    # Sending Feedback and grade back to canvas
    $feedback_body = @{"comment[text_comment]"=$feedback;"submission[posted_grade]"=$grade};

    Invoke-RestMethod -Uri "$($grading_url)/$($student_id)" -Method PUT -Body $feedback_body -headers $headers -ContentType "multipart/form-data";

}
