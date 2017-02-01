%Program:Momentum Assignment
%Author: Abdullah Farouk
%Last Modified: 2015-10-04
%Courses: Topics in Finance 1
%Project: Assignment 1: Momentum Trading
%Purpose: Submission of Assignment 1
%
%
%Momentum Inclass
   
% Inputs
%               File named momentumAssignment20042008.csv
%               Create a dataset - momentum which is a 283332x6 matrix
%               Each column of the momentum matrix specifies an input variable which corresponds to 283332 different entries
%
%Input Parameters and Variables:
%               PERMNO - company code which is unique to each stock 
%               DateOfObservation - the time in year/month/day of the observations
%               Returns - the returns of the stock at a particular time for the corresponding stock or PERMNO as we said earlier
%               PriceOrBid_AskAverage - The bid-ask average of the price of at a particular time for the corresponding stock or PERMNO as we said earlier
%               adjustedPrice - Ask Evan
%               marketCap - the value of equity for the corresponding to the adjustedPrice, time period and stock as specified by PERMNO
%                  
%
%Outputs:
%       year - the year corresponding to each observation in DateOfObservation
%       month - the month corresponding to each observation in DateOfObservation
%       momentum - the adjusted price of each stock 1 month back divided by the adjusted price of the same stock 12 months back  
%       
%   
   
   %%0-Set up
   %Set Working Directory (Note that this directory is specific to our
   %computer)
   cd('P:\MATLAB\MATLAB');
   
   
   %%1 - Import data

   momentum=dataset('File','momentumAssignment20042008.csv','Delimiter',',');  
   % we create new variables in the dataset for year and month to separate the year and month for each DateOfObservation by using the floor and rem functions
   momentum.year=floor(momentum.DateOfObservation/10000)  
   momentum.month=floor(rem(momentum.DateOfObservation,10000)/100)  
   % we create a new variable in the dataset called momentum to store the momentum calculated. If it is zero, the code replaces zero with NaN
   momentum.momentum=0;
   momentum.momentum(momentum.momentum==0)=NaN;
    
   % we run a for loop to calculate momentum, the variable we created in the previous string
   for(i=1:size(momentum,1))
      
      %  i/size(momentum,1) 
      if mod(i,1000)==0
          i
      end
      % we create a variable for the year we are observing, and repeat this for each entry using the (i) function
      thisYear=momentum.year(i)
      % we create a variable for the month we are observing, and repeat this for each entry using the (i) function
      thisMonth=momentum.month(i)
      % we create a PERMNO for the month we are observing, and repeat this for each entry using the (i) function
      thisPermno=momentum.PERMNO(i)
     % we define the previous year from our current year observation 
      lag12MYear=thisYear-1;
     % we define the month in the previous year from our current month observation  
      lag12MMonth=thisMonth;
      % we define the previous month from our current month observation 
      lag1MMonth=thisMonth-1;
      % we define the year of the previous month from our current month observation 
      lag1MYear=thisYear;
      % we run an if loop to ensure that if the previus month from the current month 
      %observation takes on a value of zero then it automatically becomes the 12th month of the previous year 
      if lag1MMonth==0
          lag1MMonth=12;
          lag1MYear=thisYear-1;
      end
      % adjusted price is the one which is already adjusted for stock
      % splits and dividends, which the Ask_BidAverage Price does not
      % account for. Hence, adjusted price is the variable you want to use
      % because it captures your actual returns
      
      
      
      % we define the formula for price of a particular stock in the previous month from the current month observation
       lag1Price= momentum.adjustedPrice(momentum.PERMNO==thisPermno&momentum.year==(lag1MYear)&momentum.month==(lag1MMonth));
      % we define the formula for price of a particular stock 12 months(or 1 year) back from the current month observation
       lag12Price=momentum.adjustedPrice(momentum.PERMNO==thisPermno&momentum.year==(lag12MYear)&momentum.month==(lag12MMonth));
      % we define our current momentum calculation as a ratio of the price of a particular stock in the previous month from the current month...
      % observation to the price of a particular stock 12 months(or 1 year) back from the current month observation
       thisMonmentum=lag1Price/lag12Price;
       
       % we define an if loop to ensure that if the momentum calculation is empty (for instance for the first 12 months we cannot calculate
       % momentum due to lack of previous months data)then the calculation retuns NaN. Otherwise it returns the momentum based on the formula
       % we defined earlier
       if(isempty(thisMonmentum))
           %nothingHappens
       else
       % this code will ensure the momentum variable in the dataset returns momentum calculated based on our formula for each entry (as done by the (i) function)    
           momentum.momentum(i)=thisMonmentum;
       end
       %%
   end
       
   
  
  
 %%3 - calculate momentum ranks, from i(lowest) to 10(highest),with tiedrank
 % we define a new variable called date which will drop all the same DateOfObservation entries into one DateOfObsrvation entry i.e. if there 10 entries for 20040501 only one 20040501 will show 
 date=unique(momentum.DateOfObservation);
 % we create a new dataset based on the new variable we created above
 output=dataset(date);
 % we create a new variable with the output dataset called year which takes only the year out of the date using the floor function
 output.year=floor(output.date/10000);
 % we create a new variable with the output dataset called month which takes only the month out of the date using the floor and rem functions
 output.month=floor(rem(output.date,10000)/100);
 
 % we run a for loop for the output dataset to segregate momentum based on quantiles and then pick winners from above the 9th out of 10 quantiles
 % and losers from the 1st out of 10 quantiles
 for (i=1:size(output,1))
    % we defined i as each entry for the output dataset 
     i
    % we define each year in the year variable of the dataset for each entry
     thisYear=output.year(i);
    % we define each month in the month variable of the dataset for each entry 
    thisMonth=output.month(i);
    % we separate momentum calculated into 9 quantiles
    momentumQuantiles=quantile(momentum.momentum(momentum.year==thisYear & momentum.month==thisMonth),9);
    % we create a new variable in the output dataset to get the mean of all momentum Returns less than the first quantile momentum number 
    output.mom1(i)=mean(momentum.Returns(momentum.year==thisYear & momentum.month==thisMonth & momentum.momentum<=momentumQuantiles(1)));
    % we create a new variable in the output dataset to get the mean of all momentum Returns greater than the 9th quantile momentum number
    output.mom10(i)=mean(momentum.Returns(momentum.year==thisYear & momentum.month==thisMonth & momentum.momentum>=momentumQuantiles(9)));
    % for each entry in the output dataset (defined by (i) function) we
    % take the difference of the mean of all momentum Returns greater than
    % the 9th quantile momentum number and the mean of all momentum Returns less than the first quantile momentum number
    output.mom(i)=output.mom10(i)-output.mom1(i);
 end
 
 %%4 - Plot cumulative log returns
 % we create a new variable in the output dataset for Cumulative Returns of
 % the portfolio and set it as NaN
 output.cumRet=NaN;
 
 % to define the Cumulative Returns other than the empty ones, we use a
 % for loop
 for  (i=2:size(output,1))
     % we use each entry in the output dataset starting from the second entry  
     i
     % we again use the if loop to return NaN if the output.mom(i) is empty
     % and not hinder our code's progress
       if isnan(output.mom(i))
           output.cumRet(i)=NaN;
           % this if loop ensures that if the previous entry is NaN there
           % will be no compounding of returns in the current cell
       elseif isnan(output.cumRet(i-1))
           output.cumRet(i)=1+output.mom(i);
           % if the above function is not true for the ith entry then the
           % else command will give a formula for the compounded
           % cumulative returns
       else
           output.cumRet(i)=output.cumRet(i-1)*(1+output.mom(i))
       end
 end
 
 %% 5 - Plotting graphs
 % we use the plot function to get graph of cumulative returns against time
 % to show our momentum strategy's results
 plot (output.cumRet)
 % we edit the labels under the Edit>Axes Properties option


 
 
         
   