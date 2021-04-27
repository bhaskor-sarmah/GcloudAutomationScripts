#!/bin/bash
# Asumming the $RESOURCE_FOLDER folder name to be $RESOURCE_FOLDER

# Please ensure gcloud is install and firebase-tools, initialize account details
# create a projects folder containing $companyname-projectid-timestamp.txt that contains the log

echo "Enter User Email Id:"
#read USER_EMAIL
USER_EMAIL="bhaskor88@gmail.com"
echo "Enter Project Id:"
#read PROJECT_ID
PROJECT_ID="test-proj-0027"
echo "Enter Project Name:"
#read PROJECT_NAME
PROJECT_NAME="test-proj-0027-name"
echo "Enter Repository Name:"
#read REPO_NAME
REPO_NAME="test-repo-0027"
echo "Enter Storage Bucket Name (Use only lowercase letters, numbers, hyphens (-), and underscores (_). Dots (.) may be used to form a valid domain name.):"
#read BUCKET_NAME
BUCKET_NAME="test-proj-0027-bucket-name"
echo "Enter React Template Folder Name:"
#read REACT_TEMPLATE
REACT_TEMPLATE="react-template"
echo "Enter Billing Account ID:"
#read BILLING_ID
BILLING_ID="018988-9D4F78-2781DD"

RESOURCE_FOLDER="joinWeb_DB"
CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")
touch ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt

# Create a new Project named - [Project Name from Input] having Project ID -  [Project ID from Input]
echo "Creating New Project...."
gcloud projects create $PROJECT_ID --name=$PROJECT_NAME >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
PROJECT_NUM=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")
gcloud config set project $PROJECT_ID >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Getting Project Number - $PROJECT_NUM"
echo "Completed Creating New Project !"

# this is gcloud authorization cookie
eval 'set +o history' 2>/dev/null || setopt HIST_IGNORE_SPACE 2>/dev/null
 touch ~/.gitcookies
 chmod 0600 ~/.gitcookies
 git config --global http.cookiefile ~/.gitcookies
 tr , \\t <<\_END_ >>~/.gitcookies
source.developers.google.com,FALSE,/,TRUE,2147483647,o,git-joinwebcloud.gmail.com=1//03WkBhkfH8DceCgYIARAAGAMSNwF-L9Ir7qM6eMelXvdHpeQim9ISHUKd6CJ2Jnzxt4tMrjuX9QuZ5wHmnaodro1iRMX4i7_2aTw
_END_
eval 'set -o history' 2>/dev/null || unsetopt HIST_IGNORE_SPACE 2>/dev/null

echo "Connecting the new project with the billing account...."
echo "Warning Alpha Command might be removed without any notice"
gcloud services enable cloudbilling.googleapis.com >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
# -y flag
gcloud beta billing projects link $PROJECT_ID  --billing-account=$BILLING_ID >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt

echo "Completed connection to billing account !"

# Create a empty repository
echo "Creating New Repository...."
gcloud config set project $PROJECT_ID >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
# -y flag
gcloud services enable sourcerepo.googleapis.com >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud source repos create $REPO_NAME >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Completed New Repository !"

echo "Creating Cloud Bucket...."
gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Completed Creating Cloud Bucket !"

echo "Uploading Folder to Bucket...."
gcloud projects add-iam-policy-binding $PROJECT_ID  --member="user:$USER_EMAIL" --role="roles/storage.admin" >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gsutil cp -r ./$RESOURCE_FOLDER gs://$BUCKET_NAME/ >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Completed Uploading Folder to Bucket !"

echo "Creating Config File"
# Go Inside the template Directory
cd $REACT_TEMPLATE >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
#npm install
# touch templateUrl.conf
# echo "{
#         \"bucketUrl\":\"https://storage.cloud.google.com/$BUCKET_NAME/$RESOURCE_FOLDER/\"
#     }" > templateUrl.conf

touch cloudbuild.yaml
echo "steps:
        # copy files from cloud bucket
      - name: 'gcr.io/cloud-builders/gsutil'
        args: ['cp','-r','gs://$BUCKET_NAME/$RESOURCE_FOLDER', './public/']
        # Install
      - name: 'gcr.io/cloud-builders/npm'
        args: ['install']
        # Build
      - name: 'gcr.io/cloud-builders/npm'
        args: ['run', 'build']
        # Deploy
      - name: gcr.io/$PROJECT_ID/firebase
        args: ['deploy', '--project=$PROJECT_ID', '--only=hosting']" > cloudbuild.yaml


echo "Creating Firebase hosting...."
# firebase init hosting - Create firebase.json and .firebaserc
rm .firebaserc
rm firebase.json
firebase init hosting
git add .
git commit -m "Added Bucket Config File and Cloud Build File and Firebase Hosting"
echo "Completed Creating Config File"

# Add Remote to the local repository
echo "Adding Repository to React Template...."

git config credential.helper gcloud.sh >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
git remote remove google >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
git remote add google https://source.developers.google.com/p/$PROJECT_ID/r/$REPO_NAME >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
# git push --all google
echo "Completed Adding Repository to React Template !"


echo "Creating Service Accounts with Roles...."
echo "Enabling the cloudbuild API"
gcloud services enable cloudbuild.googleapis.com >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt

echo "Providing IAM roles"
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com --role roles/compute.admin >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com --role roles/iam.serviceAccountUser >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com --role roles/iam.serviceAccountTokenCreator >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com --role roles/firebase.admin >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com --role roles/serviceusage.apiKeysAdmin >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Completed Providing IAM roles"
echo "Completed Creating Service Accounts with Roles !"

# echo "Initializing Cloud Build...."
git clone https://github.com/GoogleCloudPlatform/cloud-builders-community.git >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
cd cloud-builders-community/firebase/
gcloud builds submit --config cloudbuild.yaml >> ../../projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
cd ../..
rm -rf cloud-builders-community/
git add .
git commit -m "Added Cloud Build"

echo "Creating Build Trigger...."
gcloud beta builds triggers create cloud-source-repositories  --name="build-trigger" --repo=$REPO_NAME --branch-pattern="^master$"  --build-config="cloudbuild.yaml" >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
# Disabling the trigger
gcloud beta builds triggers export "build-trigger" --destination=../trigger.yaml >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "disabled: True" >> ../trigger.yaml
gcloud beta builds triggers import --source=../trigger.yaml >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Completed Creating Build Trigger !"

# Pushing to cloud repository
echo "Pushing React Template to Remote Repository...."
git push --all google >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Completed Pushing React Template to Remote Repository !"


# CREATING CLOUD SCHEDULER
echo "CREATING CLOUD SCHEDULER"
MESSAGE_BODY="{\"branchName\":\"master\"}"

TRIGGERID=$(head -3 ../trigger.yaml | tail -1)
TRIGGERID="${TRIGGERID:4}"

URL="https://cloudbuild.googleapis.com/v1/projects/$PROJECT_ID/triggers/$TRIGGERID:run"

gcloud iam service-accounts create "cloud-build-trigger" \
    --display-name="Cloud Build Trigger" >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:cloud-build-trigger@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudbuild.builds.editor" >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud services enable cloudscheduler.googleapis.com >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud services enable appengine.googleapis.com >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud app create --region=europe-west >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud config set project $PROJECT_ID >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
gcloud beta scheduler jobs create http trigger-cloud-build-job --schedule="0/30 12-22 * * *" --uri="https://cloudbuild.googleapis.com/v1/projects/$PROJECT_ID/triggers/$TRIGGERID:run" --http-method="POST" --time-zone="Europe/Rome" \
--message-body=$MESSAGE_BODY --oauth-service-account-email="cloud-build-trigger@$PROJECT_ID.iam.gserviceaccount.com" >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "COMPLETED CREATING CLOUD SCHEDULER"
echo "Running the build from command"
gcloud beta builds triggers run --branch=master build-trigger >> ./projects/$PROJECT_NAME-$PROJECT_ID-$CURRENT_TIME.txt
echo "Build command started successfully"
echo "script completed successfully"