## About Prisma CLI

[Prisma](https://www.prisma.io/) is a next-generation ORM (Object-Relational Mapping) tool for Node.js and TypeScript. The Prisma CLI is used to:

- **Schema Management** - Define your database schema using Prisma Schema Language
- **Database Migrations** - Create and apply database migrations
- **Database Introspection** - Generate Prisma schema from existing databases
- **Prisma Client Generation** - Generate type-safe database client
- **Database Seeding** - Populate your database with initial data
- **Studio** - Open Prisma Studio for visual database management

## Installation Method

This feature installs Prisma CLI globally using npm. It requires Node.js and npm to be installed first.

## Prerequisites

**Important**: This feature requires Node.js to be installed. Make sure to include the Node.js feature before Prisma CLI:

```json
{
  "features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/YOUR_USERNAME/stripe-cli/prisma-cli:1": {}
  }
}
```

## Usage

### Initialize Prisma in your project

```bash
# Initialize Prisma with PostgreSQL
prisma init --datasource-provider postgresql

# Or with other databases
prisma init --datasource-provider mysql
prisma init --datasource-provider sqlite
prisma init --datasource-provider mongodb
```

### Define your schema

Edit `prisma/schema.prisma`:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id])
  authorId  Int
}
```

### Common Commands

```bash
# Generate Prisma Client
prisma generate

# Create a migration
prisma migrate dev --name init

# Apply migrations
prisma migrate deploy

# Reset database
prisma migrate reset

# Introspect existing database
prisma db pull

# Push schema changes without migrations
prisma db push

# Open Prisma Studio
prisma studio

# Format schema file
prisma format

# Validate schema
prisma validate
```

### Using with TypeScript

```typescript
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // Create a user
  const user = await prisma.user.create({
    data: {
      name: 'Alice',
      email: 'alice@example.com',
    },
  })

  // Query all users
  const users = await prisma.user.findMany()
  
  console.log(users)
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

## Database Support

Prisma supports multiple databases:
- PostgreSQL
- MySQL
- SQLite
- MongoDB
- Microsoft SQL Server
- CockroachDB
- PlanetScale

## OS Support

Works on any system with Node.js and npm installed, including:
- Ubuntu-based containers
- Debian-based containers
- Alpine Linux
- macOS

## Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Getting Started Guide](https://www.prisma.io/docs/getting-started)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [Prisma Client API](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)
- [GitHub Repository](https://github.com/prisma/prisma)

