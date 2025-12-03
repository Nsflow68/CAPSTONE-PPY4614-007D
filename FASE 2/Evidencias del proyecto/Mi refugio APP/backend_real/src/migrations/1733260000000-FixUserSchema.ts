import { MigrationInterface, QueryRunner } from "typeorm";

export class FixUserSchema1733260000000 implements MigrationInterface {
    name = 'FixUserSchema1733260000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Add columns if they don't exist
        await queryRunner.query(`
            DO $$ 
            BEGIN 
                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'app' AND table_name = 'users' AND column_name = 'rut') THEN 
                    ALTER TABLE "app"."users" ADD COLUMN "rut" character varying DEFAULT 'TEMP-RUT';
                END IF;

                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'app' AND table_name = 'users' AND column_name = 'birthDate') THEN 
                    ALTER TABLE "app"."users" ADD COLUMN "birthDate" TIMESTAMP;
                END IF;

                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'app' AND table_name = 'users' AND column_name = 'gender') THEN 
                    ALTER TABLE "app"."users" ADD COLUMN "gender" character varying;
                END IF;

                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'app' AND table_name = 'users' AND column_name = 'createdAt') THEN 
                    ALTER TABLE "app"."users" ADD COLUMN "createdAt" TIMESTAMP DEFAULT now();
                END IF;

                IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'app' AND table_name = 'users' AND column_name = 'updatedAt') THEN 
                    ALTER TABLE "app"."users" ADD COLUMN "updatedAt" TIMESTAMP DEFAULT now();
                END IF;
            END $$;
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // No-op for safety, or drop columns if needed
    }
}
