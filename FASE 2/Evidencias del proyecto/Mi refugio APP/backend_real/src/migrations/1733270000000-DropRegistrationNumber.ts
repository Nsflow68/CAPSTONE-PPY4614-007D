import { MigrationInterface, QueryRunner } from "typeorm";

export class DropRegistrationNumber1733270000000 implements MigrationInterface {
    name = 'DropRegistrationNumber1733270000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Check if column exists before dropping to avoid errors
        await queryRunner.query(`
            DO $$ 
            BEGIN 
                IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'app' AND table_name = 'users' AND column_name = 'registrationNumber') THEN 
                    ALTER TABLE "app"."users" DROP COLUMN "registrationNumber" CASCADE;
                END IF;
            END $$;
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Re-add the column if rolling back (optional, nullable to be safe)
        await queryRunner.query(`
            ALTER TABLE "app"."users" ADD COLUMN "registrationNumber" character varying;
        `);
    }
}
