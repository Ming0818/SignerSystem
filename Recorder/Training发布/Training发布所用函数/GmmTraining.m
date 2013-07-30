function [alpha,Mu,Variances]=GmmTraining(Input,No_of_Cluster,Iteration,maxtrain)%����Input���д洢
%����˵����ѧϰ
%Input��������
%
%
%%%%%%%%%%%��ʼ��
  Plimitation=0.001;%������Сֵ
  Climitation=6.5;
  Covarlimit=0.1;
  [IDX, Initial_Centroid] = kmeans(Input',No_of_Cluster);%IDX�洢ÿ����ľ����ţ�Initial_Centroids��������λ��
  Mu = Initial_Centroid';%%��ʼ����ֵ��Mu���д洢
  Muold=Mu;
  [No_of_Feature,   No_of_Data_Point] = size(Input);%���д洢
  [PNC,INDEX] = Cluster_Probability(Input,Mu);
  alphaold=zeros(No_of_Cluster);
  alpha=zeros(No_of_Cluster);
  %��ʼ��alpha
  alpha=PNC;%alpha���д洢
  alphaold=alpha;
  
  COVAR=zeros(No_of_Feature,No_of_Cluster);%%���ʼ��׼�����׼��洢
  COVARold=zeros(No_of_Feature,No_of_Cluster);
  COVAR= Cluster_Covariance(Input,IDX,No_of_Cluster);%����ÿ������ı�׼��
  %Covartemp=zeros(No_of_Feature,   No_of_Cluster);
  %for i=1:No_of_Cluster%%%%��ÿ���������ȫ����ķ���
  %    for j=1:No_of_Data_Point
  %   Covartemp(:,i)=Covartemp(:,i)+(Input(:,j)-Mu(:,i)).^2;%
  %    end
  %end
  %COVAR=sqrt(Covartemp);

  COVARold=COVAR;
 
  %%%%%%%%%����
  belta=zeros(No_of_Cluster,No_of_Data_Point);
  beltad=zeros(No_of_Data_Point);
  beltasum=zeros(No_of_Cluster);
  Limit=1;
  time=0;
  SqrtPi=sqrt(2*pi);
  Limitold=1000;
  while(Limit>Iteration&&time<maxtrain)
     time=time+1;
     Probability(1:No_of_Cluster,   1:No_of_Data_Point) = 1.0;
     [No_of_Feature,   No_of_Data_Point] = size(Input);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%ȫЭ����
     %   for i= 1:No_of_Cluster
     %       New=(Input-repmat(Mu(:,i),1,No_of_Data_Point))'/COVAR';
     %       
     %       Mah=sum(New.^2,2);%%%ֵ̫���ø���Ϊ0
     %       Mah=Mah./(sum(Mah)/No_of_Data_Point);
     %       exph=exp(-0.5*Mah');
     %       %exph=exph./max(exph);
     %       Probability(i,:)=(2*pi)^(No_of_Feature/2)/det(COVAR)*exph;%%%%���ʼ������Ϊ0
     %   end   
     %    Probability=abs(Probability)./max(max(abs(Probability)));
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        Probability=Probabilitys(No_of_Cluster,No_of_Feature,Input, alpha,Mu,COVAR);
        %%%%%%%%%%E-step
        
         %%%%%%%%%%%%%%%%%%%%%%%%%
         %beltau=Probability*0;
         %for j= 1:No_of_Data_Point%%����belta
         %    beltad(j)=0.0;
         %    for i= 1:No_of_Cluster   
         %       beltau(i,j)=alpha(i)*Probability(i,j);
         %       beltad(j)=beltad(j)+beltau(i,j);
         %    end
         %    belta(:,j)=beltau(:,j)/beltad(j);
         %end
         %for i= 1:No_of_Cluster
         %beltasum(i)=sum(belta(i,:));
         %end
         %%%%%%%%%%%%%%%%%%%%%%%%%
         alp=repmat(alpha',1,No_of_Data_Point);
         beltau=alp.*Probability;%%ĳЩ֡�����еľ��඼������
         beltad=sum(beltau);%%%���ַ�ĸΪ0�����������ĸΪ0�ĵ�����
         discard=0;
         i=1;
         while i+discard<=No_of_Data_Point%�ҳ���ĸΪ0������
             if beltad(i)==0
                 while beltad(No_of_Data_Point-discard)==0
                    discard=discard+1;
                 end
                 Probability(:,i)=Probability(:,No_of_Data_Point-discard);
                 beltad(i)=beltad(No_of_Data_Point-discard);
                 beltau(:,i)=beltau(:,No_of_Data_Point-discard);
                 Input(:,i)=Input(:,No_of_Data_Point-discard);
                 discard=discard+1;
             end
             i=i+1;
         end
         if discard~=0%����ĸΪ0����������
            No_of_Data_Point=No_of_Data_Point-discard;
            Input=Input(:,1:No_of_Data_Point);
            Probability=Probability(:,1:No_of_Data_Point);
            beltau=beltau(:,1:No_of_Data_Point);
            beltad=beltad(:,1:No_of_Data_Point);
         end
         belta=beltau./repmat(beltad,No_of_Cluster,1);
         beltasum=sum(belta,2);
         
         %%%%%%%%%%%%M-step
        Muold=Mu;
        for i= 1:No_of_Cluster%%����Mu
             Mu(:,i)=Input*belta(i,:)'/beltasum(i); 
        end
        COVARold=COVAR;%%%%�ġ�����Խ�Э������ټ�������
        
        for i= 1:No_of_Cluster%%����COVAR
                Mu2=repmat(Mu(:,i),1,No_of_Data_Point);
                COVAR(:,i)=((Input-Mu2).^2)*belta(i,:)'/(beltasum(i)); 
        end
        COVAR=sqrt(COVAR);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%ȫЭ����
        %COV=COVAR;
        %for i= 1:No_of_Cluster%%����COVAR
        %    Mui=repmat(Mu(:,i)',No_of_Data_Point,1);
        %    COV0=repmat(belta(i,:)',1,No_of_Feature);
        %    COV1=((Input'-Mui).*COV0)';
        %    COV2=COV1*(Input'-Mui);
        %    COV=COV2./repmat(beltasum(i,1),No_of_Feature,No_of_Feature);
        %    [U,L,V]=svd(COV);
        %    H=diag(L);
        %    if(min(H)>eps) && (max(H)/min(H)<1e4)
        %        [COVi,p]=chol(COV);
        %        if p==0
        %            COVAR=COVi';
        %        end
        %    end
        %end
        %%%%%%%%%%%%%%%%%%%%%%%
        alphaold=alpha;
        for i=1:No_of_Cluster%%����alpha
            alpha(i)=beltasum(i)/No_of_Data_Point;
        end
        alpha=alpha./sum(alpha);
        mean_alpha=repmat(mean(alpha),1,No_of_Cluster);
        mean_covar=repmat(mean(mean(abs(COVAR))),No_of_Feature,No_of_Cluster);
        mean_mu=repmat(mean(mean(abs(Mu))),No_of_Feature,No_of_Cluster);
        alpha_new=max((abs(alpha-alphaold)+abs(alphaold)+mean_alpha)./(abs(alphaold)+mean_alpha));
        covar_new=max(mean((abs(COVAR-COVARold)+abs(COVARold)+mean_covar)./(abs(COVARold)+mean_covar)));
        mu_new=max(max((abs(Mu-Muold)+abs(Muold)+mean_mu)./(abs(Muold)+mean_mu)));
        Limit=(alpha_new+covar_new+mu_new-3)/3;
        if Limit>Limitold
            alpha=(3*alphaold+alpha)/4;
            Mu=(Mu+3*Muold)/4;
            COVAR=(COVAR+3*COVARold)/4;
       
        else
            alpha=(alphaold+3*alpha)/4;
            Mu=(3*Mu+Muold)/4;
            COVAR=(3*COVAR+COVARold)/4;    
            
            
        end     
        Limitold=Limit;
        fprintf('time=%d,         limit=%f\n',time,Limit);
        %Limit=alpha_new+covar_new/(No_of_Cluster)+mu_new/(No_of_Cluster)
 end%While
       %    for i= 1:No_of_Cluster%%����COVAR
       %      for j=1:No_of_Feature
       %         if(COVAR(j,i)<Covarlimit)
       %            COVAR(j,i)=Covarlimit;
       %        end
       %     end
       % end
  Variances= COVAR;
  fprintf('\n');
  if(isfinite(max(alpha))==0)
     alpha=alphaold;
  end
  if(isfinite(max(max(Mu)))==0)
     Mu=Muold;
  end
  if(isfinite(max(max(Variances)))==0)
     Variances=COVARold;
  end
end
    


