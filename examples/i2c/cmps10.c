// to compile: gcc -o cmps10 cmps10.c
// to start sudo ./cmps10
//
// i2c CMPS10  example
//
// Reads the software bearing pitch roll magnitometer and accelerometer values
// 

#include <stdio.h>
#include <stdlib.h>
#include <linux/i2c-dev.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

void two_byte_to_short(unsigned char * bf, int pozition, short *res){
	*res = (bf[pozition] << 8) | bf[pozition+1];
}

int main(int argc, char **argv)
{

	int fd;
	char *interface = "/dev/i2c-0";
	int  address = 0x60;
	unsigned int result;
	unsigned char buf[14];
	int pitch, roll;
	short mx, my, mz, ax, ay, az;

// Open i2c interface for reading and writing
	if ((fd = open(interface, O_RDWR)) < 0) { 
		printf("Failed to open i2c port\n");
		exit(1);
	}

// Set the port address of the device we wish to speak to
	if (ioctl(fd, I2C_SLAVE, address) < 0) {
		printf("Unable to set slave address\n");
		exit(1);
	}

// set starting register - according CMPS10 documentation
	while (1) {
		sleep(1);
		buf[0] = 2;
		if ((write(fd, buf, 1)) != 1) {
			printf("Error writing to i2c slave\n");
			exit(1);
		}

// Read back data into buf[]
		if (read(fd, buf, 4) != 4) {
			printf("Unable to read from slave\n");
			exit(1);
		}

		result = (buf[0] <<8) + buf[1];
		printf("Bearing: %u.%u\t",result / 10, result %10);
		pitch = buf[2]; if (buf[2] > 128) pitch = -1*(256-buf[2]); 
		roll =  buf[3]; if (buf[3] > 128)  roll = -1*(256-buf[3]);
		printf("Pitch: %d\t", pitch);
		printf("Roll: %d\n",  roll);

// reading  magnitometer and accelerometer values - according CMPS10 documentation
                buf[0] = 10;
                if ((write(fd, buf, 1)) != 1) {
                        printf("Error writing to i2c slave\n");
                        exit(1);
                }


                if (read(fd, buf, 12) != 12) {
                        printf("Unable to read from slave\n");
                        exit(1);
                }
		two_byte_to_short(buf, 0, &mx);
                two_byte_to_short(buf, 2, &my);
                two_byte_to_short(buf, 4, &mz);
		printf ("Mx: %d\tMy: %d\t\tMz %d\n", mx, my, mz);
                two_byte_to_short(buf, 6, &ax);
                two_byte_to_short(buf, 8, &ay);
                two_byte_to_short(buf, 10, &az);
                printf ("Ax: %d\tAy: %d\t\tAz %d\n-----------------------------------\n", ax, ay, az);

	}
	return 0;
}

