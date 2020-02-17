#include<iostream>
#include<fstream>
#include<cstring>
using namespace std;
int main()
{
	char* decode(char* , int , int* , char* ,int);
	int i,j;
	//read in MIPS code
	ifstream fin;
	fin.open("ins.txt",ios_base::in);
	char MIPS_code[100];
	char MIPS_code_replicate[100];
	char machine_code[1000][33];
	for(i=0;i<1000;i++)
		for(j=0;j<33;j++)
			machine_code[i][j]=0;
	//decode
	char *op=NULL;
	char *labelname=NULL;
	char label[100][20];
	char* islabel;
	int labelnum=0;
	int labelpos[100];
		//先读取出MIPS代码中全部的标签,确定这些标签的内容和位置
	j=0;
	while(!fin.eof()&&j<1000)
	{
		labelname=NULL;
		islabel=NULL;
		fin.getline(MIPS_code,100);
		strcpy(MIPS_code_replicate,MIPS_code);
		islabel=strchr(MIPS_code_replicate,':');
		if(islabel!=NULL)
		{
			labelname=strtok(MIPS_code_replicate,":");
			strcpy(label[labelnum],labelname);
			labelpos[labelnum]=j;
			labelnum++;
			j--;
		}
		j++;
	}
		//依次读取出每一条代码
	fin.close();
	fin.open("ins.txt",ios_base::in);
	j=0;
	char* code;
	while(!fin.eof()&&j<1000)
	{
		op=NULL;
		labelname=NULL;
		islabel=NULL;
		fin.getline(MIPS_code,100);
		strcpy(MIPS_code_replicate,MIPS_code);
		islabel=strchr(MIPS_code_replicate,':');
		if(islabel!=NULL)
		{
			j--;
		}
		else
		{
			code=decode(MIPS_code,labelnum,labelpos,(char *)label,j);
			for(i=0;i<33;i++)
			machine_code[j][i]=code[i];
		}
		j++;
	}
	fin.close();
	int machine_code_num=j;
	//write out machine code
	ofstream out;  
    out.open("code.txt", ios::out|ios::trunc);  
    if(out.is_open()) {  
        for(i = 0; i < machine_code_num; i++) { 
			out << "8'd"<<i<<':'<<"  "<<"data = "<<"32'b";
            for(j = 0; j < 32; j++) {  
                out << machine_code[i][j];  
             /*  if((j+1)%8 == 0 && j!=31) {  
                    out << " ";  
                } */
            }  
            if(i != machine_code_num - 1) {  
                out <<';'<<"\n";  
            }  
        }
		out<<';'<<"\n";
        cout << "compile success!" <<endl;  
        out.close();  
    } 
	return 0;
}

char* decode(char* MIPS_code, int labelnum, int* labelpos, char* label,int pc)
{
	char* getregnum(char* );
	char* getimmediate(char* );
	char* gettarget(char* ,int , int* , char* );
	char* getbranch(char* ,int , int* , char* ,int );
	char* getshamt(char* );
	char machine_code[33];
	char *op;
	char *rs;
	char *rs1;
	char *rd;
	char *rd1;
	char *rt;
	char *rt1;
	char *im;
	char *im1;
	char *branch;
	char *branch1;
	char *target;
	char *target1;
	char *shamt;
	char *shamt1;
	char MIPS_code_rep[100];
	strcpy(MIPS_code_rep,MIPS_code);
	op=strtok(MIPS_code_rep," ");
	//根据op的类型进行译码
	if(!strcmp(op,"add"))  //add $rd $rs $rt
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100000");
	}
	else if(!strcmp(op,"addu"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100001");
	}
	else if(!strcmp(op,"sub"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100010");
	}
	else if(!strcmp(op,"subu"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100011");
	}
	else if(!strcmp(op,"addi")) //addi $rt $rs immediate
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		im=strtok(NULL,"");
		im1=getimmediate(im);
		strcpy(C,im1);
		strcpy(machine_code,"001000");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"addiu"))
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		im=strtok(NULL,"");
		im1=getimmediate(im);
		strcpy(C,im1);
		strcpy(machine_code,"001001");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"and"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100100");
	}
	else if(!strcmp(op,"or"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100101");
	}
	else if(!strcmp(op,"xor"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100110");
	}
	else if(!strcmp(op,"nor"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"100111");
	}
	else if(!strcmp(op,"andi"))
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		im=strtok(NULL,"");
		im1=getimmediate(im);
		strcpy(C,im1);
		strcpy(machine_code,"001100");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"sll")) //sll $rd $rt shamt
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(B,rt1);
		shamt=strtok(NULL,"");
		shamt1=getshamt(shamt);
		strcpy(C,shamt1);
		strcpy(machine_code,"00000000000");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
		strcat(machine_code,"000000");
	}
	else if(!strcmp(op,"srl"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(B,rt1);
		shamt=strtok(NULL,"");
		shamt1=getshamt(shamt);
		strcpy(C,shamt1);
		strcpy(machine_code,"00000000000");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
		strcat(machine_code,"000010");
	}
	else if(!strcmp(op,"sra"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(B,rt1);
		shamt=strtok(NULL,"");
		shamt1=getshamt(shamt);
		strcpy(C,shamt1);
		strcpy(machine_code,"00000000000");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
		strcat(machine_code,"000011");
	}
	else if(!strcmp(op,"slt"))
	{
		char A[6];
		char B[6];
		char C[6];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		strcpy(A,rd1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		rt=strtok(NULL,"$()");
		rt1=getregnum(rt);
		strcpy(C,rt1);
		strcpy(machine_code,"000000");
		strcat(machine_code,B);
		strcat(machine_code,C);
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,"101010");
	}
	else if(!strcmp(op,"slti"))
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		im=strtok(NULL,"");
		im1=getimmediate(im);
		strcpy(C,im1);
		strcpy(machine_code,"001010");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"sltiu"))
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		im=strtok(NULL,"");
		im1=getimmediate(im);
		strcpy(C,im1);
		strcpy(machine_code,"001011");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"beq"))// beq $rt $rs branch
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		branch=strtok(NULL,"");
		branch1=getbranch(branch,labelnum,labelpos,label,pc);
		strcpy(C,branch1);
		strcpy(machine_code,"000100");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"bne"))
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		branch=strtok(NULL,"");
		branch1=getbranch(branch,labelnum,labelpos,label,pc);
		strcpy(C,branch1);
		strcpy(machine_code,"000101");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"blez"))//blez $rs branch
	{
		char A[6];
		char B[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(A,rs1);
		branch=strtok(NULL,"");
		branch1=getbranch(branch,labelnum,labelpos,label,pc);
		strcpy(B,branch1);
		strcpy(machine_code,"000110");
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,B);
	}
	else if(!strcmp(op,"bgtz"))
	{
		char A[6];
		char B[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(A,rs1);
		branch=strtok(NULL,"");
		branch1=getbranch(branch,labelnum,labelpos,label,pc);
		strcpy(B,branch1);
		strcpy(machine_code,"000111");
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,B);
	}
	else if(!strcmp(op,"bltz"))
	{
		char A[6];
		char B[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rs=strtok(NULL,"$() ");
		rs1=getregnum(rs);
		strcpy(A,rs1);
		branch=strtok(NULL,"");
		branch1=getbranch(branch,labelnum,labelpos,label,pc);
		strcpy(B,branch1);
		strcpy(machine_code,"000001");
		strcat(machine_code,A);
		strcat(machine_code,"00000");
		strcat(machine_code,B);
	}
	else if(!strcmp(op,"j"))
	{
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		target=strtok(NULL,"");
		target1=gettarget(target,labelnum, labelpos, label);
		strcpy(machine_code,"000010");
		strcat(machine_code,target1);
	}
	else if(!strcmp(op,"jal"))
	{
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		target=strtok(NULL,"");
		target1=gettarget(target,labelnum, labelpos, label);
		strcpy(machine_code,"000011");
		strcat(machine_code,target1);
	}
	else if(!strcmp(op,"jr")) //jr $rs
	{
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rs=strtok(NULL,"$()");
		rs1=getregnum(rs);
		strcpy(machine_code,"000000");
		strcat(machine_code,rs1);
		strcat(machine_code,"000000000000000001000");
	}
	else if(!strcmp(op,"jalr"))//jalr $rd $rs
	{
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rd=strtok(NULL,"$() ");
		rd1=getregnum(rd);
		rs=strtok(NULL,"$()");
		rs1=getregnum(rs);
		strcpy(machine_code,"000000");
		strcat(machine_code,rs1);
		strcat(machine_code,"00000");
		strcat(machine_code,rd1);
		strcat(machine_code,"00000");
		strcat(machine_code,"001001");
	}
	else if(!strcmp(op,"lw")) //lw $rt immediate($rs)
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		im=strtok(NULL,"(");
		im1=getimmediate(im);
		strcpy(C,im1);
		rs=strtok(NULL,"$)");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		strcpy(machine_code,"100011");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	
	}
	else if(!strcmp(op,"sw"))
	{
		char A[6];
		char B[6];
		char C[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		im=strtok(NULL,"(");
		im1=getimmediate(im);
		strcpy(C,im1);
		rs=strtok(NULL,"$)");
		rs1=getregnum(rs);
		strcpy(B,rs1);
		strcpy(machine_code,"101011");
		strcat(machine_code,B);
		strcat(machine_code,A);
		strcat(machine_code,C);
	}
	else if(!strcmp(op,"lui")) //lui $rt immediate
	{
		char A[6];
		char B[17];
		strcpy(MIPS_code_rep,MIPS_code);
		op=strtok(MIPS_code_rep," ");
		rt=strtok(NULL,"$() ");
		rt1=getregnum(rt);
		strcpy(A,rt1);
		im=strtok(NULL,"");
		im1=getimmediate(im);
		strcpy(B,im1);
		strcpy(machine_code,"001111");
		strcat(machine_code,"00000");
		strcat(machine_code,A);
		strcat(machine_code,B);
	}
	else if(!strcmp(op,"nop"))
	{
		strcpy(machine_code,"00000000000000000000000000000000");
	}
	else
	{
		return NULL;
	}
	return machine_code;
}

char* getregnum(char* r)
{
	char A[6];
	if(!strcmp(r,"zero"))
	{strcpy(A,"00000");}
	else if(!strcmp(r,"v0"))
	{strcpy(A,"00010");}
	else if(!strcmp(r,"v1"))
	{strcpy(A,"00011");}
	else if(!strcmp(r,"a0"))
	{strcpy(A,"00100");}
	else if(!strcmp(r,"a1"))
	{strcpy(A,"00101");}
	else if(!strcmp(r,"a2"))
	{strcpy(A,"00110");}
	else if(!strcmp(r,"a3"))
	{strcpy(A,"00111");}
	else if(!strcmp(r,"t0"))
	{strcpy(A,"01000");}
	else if(!strcmp(r,"t1"))
	{strcpy(A,"01001");}
	else if(!strcmp(r,"t2"))
	{strcpy(A,"01010");}
	else if(!strcmp(r,"t3"))
	{strcpy(A,"01011");}
	else if(!strcmp(r,"t4"))
	{strcpy(A,"01100");}
	else if(!strcmp(r,"t5"))
	{strcpy(A,"01101");}
	else if(!strcmp(r,"t6"))
	{strcpy(A,"01110");}
	else if(!strcmp(r,"t7"))
	{strcpy(A,"01111");}
	else if(!strcmp(r,"s0"))
	{strcpy(A,"10000");}
	else if(!strcmp(r,"s1"))
	{strcpy(A,"10001");}
	else if(!strcmp(r,"s2"))
	{strcpy(A,"10010");}
	else if(!strcmp(r,"s3"))
	{strcpy(A,"10011");}
	else if(!strcmp(r,"s4"))
	{strcpy(A,"10100");}
	else if(!strcmp(r,"s5"))
	{strcpy(A,"10101");}
	else if(!strcmp(r,"s6"))
	{strcpy(A,"10110");}
	else if(!strcmp(r,"s7"))
	{strcpy(A,"10111");}
	else if(!strcmp(r,"t8"))
	{strcpy(A,"11000");}
	else if(!strcmp(r,"t9"))
	{strcpy(A,"11001");}
	else if(!strcmp(r,"k0"))
	{strcpy(A,"11010");}
	else if(!strcmp(r,"k1"))
	{strcpy(A,"11011");}
	else if(!strcmp(r,"gp"))
	{strcpy(A,"11100");}
	else if(!strcmp(r,"sp"))
	{strcpy(A,"11101");}
	else if(!strcmp(r,"fp"))
	{strcpy(A,"11110");}
	else if(!strcmp(r,"ra"))
	{strcpy(A,"11111");}
	else
	{strcpy(A,"00000");}
	return A;
}

char* getimmediate(char* I)
{
	char A[17];
	char* p;
	p=&I[2];
	switch(p[0])
	{
	case '0':strcpy(A,"0000");break;
	case '1':strcpy(A,"0001");break;
	case '2':strcpy(A,"0010");break;
	case '3':strcpy(A,"0011");break;
	case '4':strcpy(A,"0100");break;
	case '5':strcpy(A,"0101");break;
	case '6':strcpy(A,"0110");break;
	case '7':strcpy(A,"0111");break;
	case '8':strcpy(A,"1000");break;
	case '9':strcpy(A,"1001");break;
	case 'a':strcpy(A,"1010");break;
	case 'b':strcpy(A,"1011");break;
	case 'c':strcpy(A,"1100");break;
	case 'd':strcpy(A,"1101");break;
	case 'e':strcpy(A,"1110");break;
	default:strcpy(A,"1111");
	}
	for(int i=1;i<4;i++)
	{
		char x=p[i];
		switch(x)
		{
		case '0':strcat(A,"0000");break;
		case '1':strcat(A,"0001");break;
		case '2':strcat(A,"0010");break;
		case '3':strcat(A,"0011");break;
		case '4':strcat(A,"0100");break;
		case '5':strcat(A,"0101");break;
		case '6':strcat(A,"0110");break;
		case '7':strcat(A,"0111");break;
		case '8':strcat(A,"1000");break;
		case '9':strcat(A,"1001");break;
		case 'a':strcat(A,"1010");break;
		case 'b':strcat(A,"1011");break;
		case 'c':strcat(A,"1100");break;
		case 'd':strcat(A,"1101");break;
		case 'e':strcat(A,"1110");break;
		default:strcat(A,"1111");
		}
	}
	return A;
}

char* getbranch(char* target,int labelnum, int* labelpos, char* label,int pc)
{
	int i,k;
	int branch=0;
	char q[20];
	for(i=0;i<labelnum;i++)
	{
		char t[2];
		t[0]=label[i*20];t[1]='\0';
		strcpy(q,t);
		for(k=1;k<20;k++)
		{
			if(label[i*20+k]=='\0')
				break;
			t[0]=label[i*20+k];t[1]='\0';
			strcat(q,t);
		}
		if(!strcmp(target,q))
		{
			branch=labelpos[i]-pc-1;
		}	
	}
	int t=branch;
	char* p = new char[17];  
	if(branch<0) t=-t;
        for(i = 15; i >= 0; i--) {  
            p[i] = (char)(t%2+48);  
            t=t/2;  
        }  
        if(branch<0) {  
            for(i = 15; i >= 0; i--) {  
                if(p[i] == '0') p[i] = '1';  
                else p[i] = '0';  
            }  
            int j = 15;  
            while(p[j] != '0') {  
                p[j] = '0';  
                j--;  
            }  
            if(j>=0&&p[j]=='0') {  
                p[j] = '1';  
            }  
        }  
		p[16]='\0';
	return p;
}

char* gettarget(char* branch,int labelnum, int* labelpos, char* label)
{
	int i,k;
	int target=0;
	char q[20];
	char* A = new char[27]; 
	if(branch[0]!='0'|branch[1]!='x')
	{
		for(i=0;i<labelnum;i++)
			{
				char t[2];
				t[0]=label[i*20];t[1]='\0';
				strcpy(q,t);
				for(k=1;k<20;k++)
					{
						if(label[i*20+k]=='\0')
							break;
						t[0]=label[i*20+k];t[1]='\0';
						strcat(q,t);
					}
				if(!strcmp(branch,q))
					{
						target=labelpos[i];
					}	
			}
		int t=target; 
        for(i = 25; i >= 0; i--) {  
            A[i] = (char)(t%2+48);  
            t=t/2;  
        }  
		A[26]='\0';
	}
	else
	{
		char *y=&branch[2];
		switch(y[0])
		{
		case '0':strcpy(A,"00");break;
		case '1':strcpy(A,"01");break;
		case '2':strcpy(A,"10");break;
		default:strcpy(A,"11");
		}
		for(int i=1;i<7;i++)
			{
				char x=y[i];
				switch(x)
				{
					case '0':strcat(A,"0000");break;
					case '1':strcat(A,"0001");break;
					case '2':strcat(A,"0010");break;
					case '3':strcat(A,"0011");break;
					case '4':strcat(A,"0100");break;
					case '5':strcat(A,"0101");break;
					case '6':strcat(A,"0110");break;
					case '7':strcat(A,"0111");break;
					case '8':strcat(A,"1000");break;
					case '9':strcat(A,"1001");break;
					case 'a':strcat(A,"1010");break;
					case 'b':strcat(A,"1011");break;
					case 'c':strcat(A,"1100");break;
					case 'd':strcat(A,"1101");break;
					case 'e':strcat(A,"1110");break;
					default:strcat(A,"1111");
				}
			}	
	}
	return A;
}

char* getshamt(char* shamt)
{
	char A[6];
	char* p;
	p=&shamt[2];
	switch(p[0])
	{
	case '0':strcpy(A,"0");break;
	default:strcpy(A,"1");
	}
		char x=p[1];
		switch(x)
		{
		case '0':strcat(A,"0000");break;
		case '1':strcat(A,"0001");break;
		case '2':strcat(A,"0010");break;
		case '3':strcat(A,"0011");break;
		case '4':strcat(A,"0100");break;
		case '5':strcat(A,"0101");break;
		case '6':strcat(A,"0110");break;
		case '7':strcat(A,"0111");break;
		case '8':strcat(A,"1000");break;
		case '9':strcat(A,"1001");break;
		case 'a':strcat(A,"1010");break;
		case 'b':strcat(A,"1011");break;
		case 'c':strcat(A,"1100");break;
		case 'd':strcat(A,"1101");break;
		case 'e':strcat(A,"1110");break;
		default:strcat(A,"1111");
		}
	return A;
}