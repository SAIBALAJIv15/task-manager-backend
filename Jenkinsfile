pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
        APP = 'task-manager-backend'
    }

    options {
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Building ${APP} — Branch: ${env.BRANCH_NAME ?: 'main'}"
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean compile -DskipTests'
                echo 'Compilation successful'
            }
        }

        stage('Quality') {
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
                        echo 'Code compiles cleanly'
                    }
                }
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
                echo 'JAR created in target/'
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar',
                                 fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'Pipeline SUCCESS — artifact ready!'
        }

        failure {
            echo 'Pipeline FAILED'
        }

        always {
            cleanWs()
        }
    }
}
