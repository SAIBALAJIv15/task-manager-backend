CREATE TABLE IF NOT EXISTS tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    status ENUM('PENDING', 'COMPLETED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO tasks (title, status) VALUES
('Set up CI/CD Pipeline with Jenkins', 'COMPLETED'),
('Containerize application with Docker', 'COMPLETED'),
('Deploy with Ansible automation', 'COMPLETED'),
('Configure GitHub webhooks', 'PENDING'),
('Add monitoring with CloudWatch', 'PENDING'),
('Write unit tests for all APIs', 'PENDING'),
('Set up Kubernetes cluster', 'PENDING'),
('Prepare for DevOps certification', 'PENDING');
