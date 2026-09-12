pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'saibalajiv/task-manager-backend'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'staging', 'prod'],
            description: 'Target deployment environment'
        )

        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip unit tests?'
        )
    }

    options {
        timeout(time: 20, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Quality') {
            when {
                expression { return !params.SKIP_TESTS }
            }

            parallel {

                stage('Unit Tests') {
                    steps {
                        sh 'mvn test'
                    }

                    post {
                        always {
                            junit allowEmptyResults: true,
                                  testResults: 'target/surefire-reports/*.xml'
                        }
                    }
                }

                stage('Compile Check') {
                    steps {
                        sh 'mvn compile -DskipTests'
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                    -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                    -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            when {
                branch 'main'
                expression {
                    return params.DEPLOY_ENV != 'dev'
                }
            }

            steps {
                echo "Deploying to ${params.DEPLOY_ENV}"

                sh """
                    ansible-playbook deploy-app.yml \
                    -i ansible/inventory.ini \
                    -e 'docker_image=${DOCKER_IMAGE} docker_tag=${DOCKER_TAG}'
                """
            }
        }
    }

    post {
        success {
            echo "Build #${BUILD_NUMBER} SUCCESS — deployed to ${params.DEPLOY_ENV}"
        }

        failure {
            echo "Build FAILED — check console output for errors"
        }

        unstable {
            echo "Build UNSTABLE — tests have warnings"
        }

        always {
            echo "Build URL: ${BUILD_URL}"
            cleanWs()
        }
    }
}
