import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import * as fs from 'fs';
import * as path from 'path';

const prisma = new PrismaClient();

async function main() {
  const demoEmail = process.env.DEMO_USER_EMAIL ?? 'invitado@mirefugio.cl';
  const demoPassword = await bcrypt.hash('Temporal123!', 10);

  await prisma.user.upsert({
    where: { email: demoEmail },
    update: { name: 'Invitado Mi Refugio' },
    create: {
      email: demoEmail,
      name: 'Invitado Mi Refugio',
      password: demoPassword
    }
  });

  const resourcesPath = path.join(
    __dirname,
    '..',
    'src',
    'resources',
    'resources.data.json'
  );
  const resources = JSON.parse(fs.readFileSync(resourcesPath, 'utf-8'));

  await prisma.resource.deleteMany();
  await prisma.resource.createMany({
    data: resources.map((item, index) => ({
      id: item.id ?? `resource-${index}`,
      name: item.name,
      description: item.description,
      category: item.category,
      coverage: item.coverage ?? null,
      contactPhone: item.contactPhone ?? null,
      contactEmail: item.contactEmail ?? null,
      website: item.website ?? null,
      region: item.region ?? null,
      tags: item.tags ?? []
    })),
    skipDuplicates: true
  });

  console.log('Seed ejecutado correctamente');
}

main()
  .catch((error) => {
    console.error('Error ejecutando seed Prisma:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
