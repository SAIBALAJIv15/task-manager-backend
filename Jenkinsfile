pipeline {
    agent any

    tools {
        maven 'Maven'
    }

    environment {
        APP_NAME = 'task-manager-backend'
        APP_VERSION = '1.0.0'
    }

    options {
        timeout(time: 10, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Building ${env.APP_NAME} version ${env.APP_VERSION}..."
                sh 'mvn clean package -DskipTests'
                echo 'Build complete!'
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
                echo 'All tests passed!'
            }
        }

        stage('Archive') {
            steps {
                echo 'Archiving build artifacts...'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                echo "Artifact: target/${env.APP_NAME}-${env.APP_VERSION}.jar"
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: All stages passed!'
        }

        failure {
            echo 'Pipeline FAILED! Check the logs above.'
        }

        always {
            echo "Build #${env.BUILD_NUMBER} finished."
            echo "Build URL: ${env.BUILD_URL}"
            cleanWs()
        }
    }
}
