pipeline {
  agent {
    docker {
      image 'localhost:5000/jjkeysv3'
      args '-u root'
    }
    
  }
  stages {
    stage('Pull down the ChefDK') {
      steps {
        sh '''apt-get update
apt-get install -y curl sudo git build-essential
curl -L https://chef.io/chef/install.sh | sudo bash -s -- -P chefdk -c current'''
      }
    }
    stage('Bundle') {
      steps {
        sh 'chef exec bundle install'
      }
    }
    stage('Rake') {
      steps {
        sh 'chef exec rake'
      }
    }
  }
}