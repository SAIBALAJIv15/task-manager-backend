pipeline {

    agent any

    tools {
        maven 'Maven'
    }

    environment {
        DOCKER_IMAGE_BE = 'saibalajiv/task-manager-backend'
        DOCKER_IMAGE_FE = 'saibalajiv/task-manager-frontend'
        DOCKER_TAG = "${BUILD_NUMBER}"
        FE_REPO = 'https://github.com/SAIBALAJIv15/task-manager-frontend.git'
    }

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'

                checkout scm

                dir('frontend-repo') {
                    git url: "${FE_REPO}",
                        credentialsId: 'github-credentials',
                        branch: 'main'
                }

                echo "Code checked out — Build #${BUILD_NUMBER}"
            }
        }

        stage('Build Backend') {
            steps {
                echo 'Building backend JAR with Maven...'

                sh 'mvn clean package -DskipTests -B'

                echo 'Backend JAR created in target/'
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests...'

                sh 'mvn test -B'
            }

            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker images...'

                sh "docker build -t ${DOCKER_IMAGE_BE}:${DOCKER_TAG} ."

                sh "docker tag ${DOCKER_IMAGE_BE}:${DOCKER_TAG} ${DOCKER_IMAGE_BE}:latest"

                dir('frontend-repo') {

                    writeFile file: 'Dockerfile', text: '''
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
'''

                    sh "docker build -t ${DOCKER_IMAGE_FE}:${DOCKER_TAG} ."

                    sh "docker tag ${DOCKER_IMAGE_FE}:${DOCKER_TAG} ${DOCKER_IMAGE_FE}:latest"
                }

                echo 'Docker images built successfully'
            }
        }

        stage('Docker Push') {
            steps {
                echo 'Pushing images to Docker Hub...'

                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

                    sh '''
                        echo "$DOCKER_PASS" | docker login \
                            -u "$DOCKER_USER" \
                            --password-stdin
                    '''

                    sh "docker push ${DOCKER_IMAGE_BE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE_BE}:latest"

                    sh "docker push ${DOCKER_IMAGE_FE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_IMAGE_FE}:latest"
                }

                echo 'Images pushed to Docker Hub'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to App Server via Ansible...'

                sh """
                    ansible-playbook \
                        -i ansible/inventory.ini \
                        ansible/deploy-app.yml \
                        -e "docker_image_be=${DOCKER_IMAGE_BE}" \
                        -e "docker_image_fe=${DOCKER_IMAGE_FE}" \
                        -e "docker_tag=${DOCKER_TAG}"
                """

                echo 'Deployment complete'
            }
        }

        stage('Health Check') {
            steps {
                echo 'Verifying application health...'

                sh 'sleep 15'

                sh """
                    ansible appservers \
                        -i ansible/inventory.ini \
                        -m uri \
                        -a 'url=http://localhost:8080/api/tasks/health status_code=200' \
                        --become
                """

                echo 'Application is healthy!'
            }
        }
    }

    post {
        success {
            echo "PIPELINE SUCCESS — Build #${BUILD_NUMBER} deployed!"
        }

        failure {
            echo 'PIPELINE FAILED — check console output'
        }

        always {
            sh 'docker logout || true'
            cleanWs()
        }
    }
}
