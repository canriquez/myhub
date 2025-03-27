## Fulcrum Engineering Hub

Welcome to the Fulcrum Engineering Hub GitHub repository. Fulcrum Engineering Hub is a dynamic web platform designed to enhance engagement and productivity within engineering teams. This platform serves as a centralized repository where team members can publish and access the latest documentation, technical blog posts, and project updates.

### Key Features

- **AI-Generated Content**: The platform leverages AI to generate insightful summaries, witty titles, and fun TL;DR sections, making content more engaging and accessible.
- **Interaction and Visibility**: A like system fosters interaction and increases the visibility of new content, ensuring that all engineering documentation is automatically published and promoted within the organization.
- **Powerful Search Functionality**: One of the most important features of Fulcrum Engineering Hub is its robust search functionality, enabling users to search across all internally indexed information. This helps engineering teams find the right information quickly and easily in a single place, streamlining their workflow and improving efficiency.
- **Centralized Repository**: Acts as a one-stop shop for all engineering documentation, driving collaboration and knowledge sharing within the team.

Fulcrum Engineering Hub aims to boost both writing and reading activities among engineers, fostering a culture of continuous learning and innovation.

### Getting Started

How to Start the Application Using Docker Compose
This guide will help you set up and start the application using Docker Compose. The application consists of three main services: db, rails-api, and nextjs.

Prerequisites
Ensure you have the following installed:

Docker
Docker Compose
Environment Variables
Create a .env file at the root of your project directory with the following content:

```
# Shared environment variables
GOOGLE_CLIENT_ID=<from google cloud project>
GOOGLE_CLIENT_SECRET=<from google cloud project>

# Next.js environment variables
NEXTAUTH_SECRET=<random generated secret>
NEXTAUTH_URL=http://localhost:3000

# Client-side environment variables for Next.js
NEXT_PUBLIC_DOMAIN=rayces.experientialabs.com
NEXT_PUBLIC_API_LLM_TOKEN=<api token to run llm>
NEXT_PUBLIC_RAILS_BACKEND=localhost:4000
NEXT_PUBLIC_RAILS_BACKEND_PROBE=localhost:4000/up

```

### Steps to Start the Application

Clone your project repository to your local machine. Navigate to the Project Directory

```
cd your-project-directory
```

Create a .env file in the root of your project directory and add the environment variables as shown above.

### Build and Start the Docker Containers

Run the following command to build and start the containers:

```
docker-compose up --build
```

to stop the containers

```
docker-compose down
```

### Check the Status of the Containers

You can check the status of the running containers using:

```
docker-compose ps
```

### Run Database Migrations and Seed the Database

After containers are up, run the database migrations and seed the database, execute:

```
docker-compose exec rails-api bash -c "bundle exec rails db:seed"
```

### Access the Application

#### Rails API: 
The Rails API should be accessible at `http://localhost:4000`

#### Next.js Application: 

The Next.js application should be accessible at `http://localhost:3000`
# myhub
