import { Global, Module } from '@nestjs/common';
import { DemoUserService } from './demo-user.service';

@Global()
@Module({
  providers: [DemoUserService],
  exports: [DemoUserService],
})
export class CommonModule {}
