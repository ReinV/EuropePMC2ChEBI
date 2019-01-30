#
# ChEBIplot Copyright 2018 Magnus Palmblad
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the 
# License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
# either express or implied. See the License for the specific language governing permissions and
# limitations under the License.
#
# ChEBIplot containst of R functions for plotting the mass/log P distributions as density plots
# (plot1), red-green bipartite comparisons (plot2) and tripartite comparisons as an RBG plot (plot3). 
#
# The functions can be used to visualize distributions of calculated mass and predicted log P for a 
# large number of named-entity recognitions in the scientific literature. The input to the functions 
# are tables of mass and logP, the "root" scaling and whether or not the comparisons should be
# relative (normalized) or absolute.
#
# Most parameters are hard-coded, giving a fixed but generally visually pleasing output.
#

# 2D gaussian blur kernel, SDx=2, SDy=1
WDW<-matrix(c(3.435E-09, 2.2213E-08, 1.08546E-07, 4.17925E-07, 1.25836E-06, 2.96532E-06, 5.46921E-06, 7.89638E-06, 8.92459E-06, 7.89638E-06, 5.46921E-06, 2.96532E-06, 1.25836E-06, 4.17925E-07, 1.08546E-07, 2.2213E-08, 3.435E-09,
              8.9655E-08, 5.79769E-07, 2.8331E-06, 1.0908E-05, 3.28436E-05, 7.73962E-05, 0.000142749, 0.000206099, 0.000232936, 0.000206099, 0.000142749, 7.73962E-05, 3.28436E-05, 1.0908E-05, 2.8331E-06, 5.79769E-07, 8.9655E-08,
              9.0897E-07, 5.87801E-06, 2.87235E-05, 0.000110591, 0.000332986, 0.000784684, 0.001447262, 0.00208954, 0.002361625, 0.00208954, 0.001447262, 0.000784684, 0.000332986, 0.000110591, 2.87235E-05, 5.87801E-06, 9.0897E-07,
              3.62598E-06, 2.3448E-05, 0.000114581, 0.000441161, 0.001328317, 0.003130188, 0.005773285, 0.008335403, 0.00942078, 0.008335403, 0.005773285, 0.003130188, 0.001328317, 0.000441161, 0.000114581, 2.3448E-05, 3.62598E-06,
              5.74392E-06, 3.7144E-05, 0.000181508, 0.000698844, 0.002104189, 0.004958535, 0.009145469, 0.013204123, 0.01492347, 0.013204123, 0.009145469, 0.004958535, 0.002104189, 0.000698844, 0.000181508, 3.7144E-05, 5.74392E-06,
              3.62598E-06, 2.3448E-05, 0.000114581, 0.000441161, 0.001328317, 0.003130188, 0.005773285, 0.008335403, 0.00942078, 0.008335403, 0.005773285, 0.003130188, 0.001328317, 0.000441161, 0.000114581, 2.3448E-05, 3.62598E-06,
              9.0897E-07, 5.87801E-06, 2.87235E-05, 0.000110591, 0.000332986, 0.000784684, 0.001447262, 0.00208954, 0.002361625, 0.00208954, 0.001447262, 0.000784684, 0.000332986, 0.000110591, 2.87235E-05, 5.87801E-06, 9.0897E-07,
              8.9655E-08, 5.79769E-07, 2.8331E-06, 1.0908E-05, 3.28436E-05, 7.73962E-05, 0.000142749, 0.000206099, 0.000232936, 0.000206099, 0.000142749, 7.73962E-05, 3.28436E-05, 1.0908E-05, 2.8331E-06, 5.79769E-07, 8.9655E-08,
              3.435E-09, 2.2213E-08, 1.08546E-07, 4.17925E-07, 1.25836E-06, 2.96532E-06, 5.46921E-06, 7.89638E-06, 8.92459E-06, 7.89638E-06, 5.46921E-06, 2.96532E-06, 1.25836E-06, 4.17925E-07, 1.08546E-07, 2.2213E-08, 3.435E-09), nrow=17, ncol=9, byrow=FALSE)

scaling<-function(intensity, root)
{
  return(intensity^(1/root))
}

plot1<-function(S1, root, normalize)
{
  M<-matrix(0, nrow=264, ncol=260)
  M1<-matrix(0, nrow=280, ncol=268)
  TEMP1<-matrix(0, nrow=280, ncol=268)
  S1x<-floor(16*S1$V2+96)
  S1y<-floor((S1$V1+6.25)/6.25); S1y[is.na(S1y)]<-FALSE
 
  max_s1<-0;
  for(x in 9:264)
  {
    for(y in 5:260) 
    {
      M1[x,y]<-sum((S1x==x-8)*(S1y==y-4))
    }
  }
  
  for(x in 9:272)
  {
    for(y in 5:264) 
    {
      for(i in -8:8) for(j in -4:4) TEMP1[x,y]<-TEMP1[x,y]+M1[x+i,y+j]*WDW[i+9,j+5]
    }
  }
  
  if(normalize==TRUE) TEMP1<-TEMP1/length(S1x)
  M1<-scaling(TEMP1, root)
  max_s1<-max(M1)
  
  plot(0, 0, type="n", xaxs="i", yaxs="i", col="black", xlim=c(-5.5,10.5), ylim=c(0,1600), xlab=expression('log'['10']*'P'['ow']), ylab='mass (Da)', xaxp=c(-5,10,15), yaxp=c(0,1600,16), las=1, bg="transparent")
  
  for(x in 1:264)
  {
    for(y in 1:260) 
    { 
      M[x,y]<- rgb(M1[x+8,y+4]/max_s1, M1[x+8,y+4]/max_s1, M1[x+8,y+4]/max_s1)
      rect(x/16-6-0.03125, y*6.25-6.25-3.125, x/16-5.9375-0.03125, y*6.25-3.125, angle=0, col=M[x,y], border=NA)
    }
  }
}

plot2<- function(S1, S2, root, normalize)
{
  M<-matrix(0, nrow=264, ncol=260)
  M1<-matrix(0, nrow=280, ncol=268)
  M2<-matrix(0, nrow=280, ncol=268)
  TEMP1<-matrix(0, nrow=280, ncol=268)
  TEMP2<-matrix(0, nrow=280, ncol=268)
  S1x<-floor(16*S1$V2+96)
  S1y<-floor((S1$V1+6.25)/6.25); S1y[is.na(S1y)]<-FALSE
  S2x<-floor(16*S2$V2+96)
  S2y<-floor((S2$V1+6.25)/6.25); S2y[is.na(S2y)]<-FALSE
  
  max_s1<-0; max_s2<-0
  for(x in 9:264)
  {
    for(y in 5:260) 
    {
      M1[x,y]<-sum((S1x==x-8)*(S1y==y-4))
      M2[x,y]<-sum((S2x==x-8)*(S2y==y-4))
    }
  }
  
  for(x in 9:272)
  {
    for(y in 5:264) 
    {
      for(i in -8:8) for(j in -4:4) {TEMP1[x,y]<-TEMP1[x,y]+M1[x+i,y+j]*WDW[i+9,j+5]; TEMP2[x,y]<-TEMP2[x,y]+M2[x+i,y+j]*WDW[i+9,j+5]}
    }
  }
  
  if(normalize==TRUE) {TEMP1<-TEMP1/length(S1x); TEMP2<-TEMP2/length(S2x)}
  M1<-scaling(TEMP1, root); M2<-scaling(TEMP2, root)
  max_s1<-max(M1); max_s2<-max(M2)
  
  plot(0, 0, type="n", xaxs="i", yaxs="i", col="black", xlim=c(-5.5,10.5), ylim=c(0,1600), xlab=expression('log'['10']*'P'['ow']), ylab='mass (Da)', xaxp=c(-5,10,15), yaxp=c(0,1600,16), las=1)
  
  for(x in 1:264)
  {
    for(y in 1:260) 
    {    
      M[x,y]<-rgb(M1[x+8,y+4]/max_s1,M2[x+8,y+4]/max_s2,0)
      rect(x/16-6-0.03125, y*6.25-6.25-3.125, x/16-5.9375-0.03125, y*6.25-3.125, angle=0, col=M[x,y], border=NA)
    }
  }
}

plot3<- function(S1, S2, S3, root, normalize)
{
  M<-matrix(0, nrow=264, ncol=260)
  M1<-matrix(0, nrow=280, ncol=268)
  M2<-matrix(0, nrow=280, ncol=268)
  M3<-matrix(0, nrow=280, ncol=268)
  TEMP1<-matrix(0, nrow=280, ncol=268)
  TEMP2<-matrix(0, nrow=280, ncol=268)
  TEMP3<-matrix(0, nrow=280, ncol=268)
  S1x<-floor(16*S1$V2+96)
  S1y<-floor((S1$V1+6.25)/6.25); S1y[is.na(S1y)]<-FALSE
  S2x<-floor(16*S2$V2+96)
  S2y<-floor((S2$V1+6.25)/6.25); S2y[is.na(S2y)]<-FALSE
  S3x<-floor(16*S3$V2+96)
  S3y<-floor((S3$V1+6.25)/6.25); S3y[is.na(S3y)]<-FALSE
  
  max_s1<-0; max_s2<-0; max_s3<-0
  for(x in 9:264)
  {
    for(y in 5:260)
    {
      M1[x,y]<-sum((S1x==x-8)*(S1y==y-4))
      M2[x,y]<-sum((S2x==x-8)*(S2y==y-4))
      M3[x,y]<-sum((S3x==x-8)*(S3y==y-4))
    }
  }
  
  for(x in 9:272)
  {
    for(y in 5:264)
    {
      for(i in -8:8) for(j in -4:4) {TEMP1[x,y]<-TEMP1[x,y]+M1[x+i,y+j]*WDW[i+9,j+5]; TEMP2[x,y]<-TEMP2[x,y]+M2[x+i,y+j]*WDW[i+9,j+5]; TEMP3[x,y]<-TEMP3[x,y]+M3[x+i,y+j]*WDW[i+9,j+5]}
    }
  }
  if(normalize==TRUE) {TEMP1<-TEMP1/length(S1x); TEMP2<-TEMP2/length(S2x); TEMP3<-TEMP3/length(S3x)}
  M1<-scaling(TEMP1[1:272,1:264], root); M2<-scaling(TEMP2[1:272,1:264], root);  M3<-scaling(TEMP3[1:272,1:264], root)
  max_s1<-max(M1); max_s2<-max(M2); max_s3<-max(M3)
  
  plot(0, 0, type="n", xaxs="i", yaxs="i", col="black", xlim=c(-5.5,10.5), ylim=c(0,1600), xlab=expression('log'['10']*'P'['ow']), ylab='mass (Da)', xaxp=c(-5,10,15), yaxp=c(0,1600,16), las=1)

  for(x in 1:264)
  {
    for(y in 1:260) 
    {    
      M[x,y]<- rgb(M1[x+8,y+4]/max_s1, M2[x+8,y+4]/max_s2, M3[x+8,y+4]/max_s3)
      rect(x/16-6-0.03125, y*6.25-6.25-3.125, x/16-5.9375-0.03125, y*6.25-3.125, angle=0, col=M[x,y], border=NA)
    }
  }
}