class Workday
    #initializing attributes
    def initialize(dayType, timeIN, timeOUT, daily_salary, max_workHours)
        @is_restday = false
        @is_holiday = false
        @is_special_non_working = false
        @is_absent = false
        @nightshift_hours = 0
        @dayshift_hours = 0
        @overTime_day = 0
        @overTime_night = 0
        @workHours = 0
        @dayPay = 0
        @daily_salary = daily_salary
        @max_workHours = max_workHours
        @hourlyRate = (@daily_salary.to_f/@max_workHours)
        @timeIN = timeIN
        @timeOUT = timeOUT
        @dayType = dayType
    end

    #this defines a dayType of a workday, parameters passed corresponds to number representing the type of day
    def define_dayType(dayType)
        case dayType
        when 0
            @is_holiday = false
            @is_special_non_working = false
            @is_restday = false
        when 1
            @is_restday = true
            @is_holiday = false
            @is_special_non_working = false
        when 2
            @is_restday = false
            @is_holiday = true
            @is_special_non_working = false
        when 3
            @is_restday = false
            @is_holiday = false
            @is_special_non_working = true
        when 4
            @is_holiday = false
            @is_restday = true
            @is_special_non_working = true
        when 5
            @is_special_non_working = false
            @is_restday = true
            @is_holiday = true
        end
    end

    #calculates the total salary of a day of the worker
    def calculate_Rate()
        #night rate
        nightRate = @hourlyRate+(@hourlyRate*0.1)

        #if time in and time out is same it means absent
        if @timeIN == @timeOUT
            @is_absent = true
        end
        
        #Normal day, but is absent
        if (@is_absent && @is_restday==false)
            @dayPay = 0.00;
            
        #Rest day, no work
        elsif (@is_absent && @is_restday)
            @dayPay = @daily_salary
            
        #Normal day
        elsif (@is_holiday==false && @is_restday==false && @is_special_non_working==false)
            # if time in is earlier than time out, means that the work is done dayshift and possibly has day or night overtime
            if @timeIN < @timeOUT
                @dayPay = @daily_salary + ((@hourlyRate*1.25)*@overTime_day) + ((@hourlyRate*1.375)*@overTime_night)

            #if the time in is later than time out means that worker might works some time on dayshift but mainly works at nightshift
            # OT is only at night
            elsif @timeIN > @timeOUT
                @dayPay = @daily_salary + ((@hourlyRate*1.10)*@nightshift_hours) +((@hourlyRate*1.375)*@overTime_night)
            end

        #Rest day
        elsif (@is_holiday==false && @is_restday==true && @is_special_non_working==false)
            payRate = (@daily_salary*1.3)
                @dayPay = payRate + ((@hourlyRate*1.69)*@overTime_day) + ((@hourlyRate*1.859)*@overTime_night)
                
        #Special non working day
        elsif (@is_holiday==false && @is_restday==false && @is_special_non_working)
            payRate = (@daily_salary*1.3)
            @dayPay = payRate + ((@hourlyRate*1.69)*@overTime_day)+ ((@hourlyRate*1.859)*@overTime_night)
    
        #Rest day and Special non working day
        elsif (@is_holiday==false && @is_restday  && @is_special_non_working)
            payRate = (@daily_salary*1.5)
            @dayPay = payRate + ((@hourlyRate*1.95)*@overTime_day)+ ((@hourlyRate*2.145)*@overTime_night)

        #Regular Holiday
        elsif (@is_holiday && @is_restday==false  && @is_special_non_working==false)
            payRate = @daily_salary*2
            @dayPay = payRate + ((@hourlyRate*2.6)*@overTime_day)+ ((@hourlyRate*2.86)*@overTime_night)
           
        #Regular Holiday, rest day, day shift
        elsif (@is_holiday && @is_restday  && @is_special_non_working==false)
            payRate = @daily_salary*2.6
            @dayPay = payRate + ((@hourlyRate*3.38)*@overTime_day)+ ((@hourlyRate*3.718)*@overTime_night)
        end
    end

    #calculates the workhours and shift hours and OT hours
    def calculate_shift_time()

        #only getting first 2 numbers representing the hours
        day_shift_start = 900/100   # 9:00 AM
        day_shift_end = 2200/100    # 10:00 PM
        night_shift_start = 2200/100  # 10:00 PM
        night_shift_end = 600/100     # 6:00 AM
        lunch_start = 1200/100       # 12:00 PM
        lunch_end = 1300/100         # 1:00 PM

        #initiated a temporary time holder
        time_IN = @timeIN
        time_OUT = @timeOUT

        #if time is 0000 it is actually 24, wont work on calculations if something is 0
        if @timeIN == 0000
            time_IN=2400
            @timeIN=2400
        elsif @timeOUT ==0000
            time_OUT=2400
            @timeOUT= 2400
        end

        time_IN /=100
        time_OUT/=100
        count_d = 0
        count_n =0
        @workHours = 0

        #array holding the shift hours of each
        work = []
        day_s =[10,11,12,13,14,15,16,17,18,19,20,21,22]
        night_s = [23,24,1,2,3,4,5,6]

        #again, if time in and time out is same the worker is absent, this thing here i think i already moved this section
        #elsewhere, it should work fine if i remove this, but im afraid to break the code so ill just retain it.
        if time_IN == time_OUT
            is_absent = true
        end
    
        #this adder is for if time counts beyond 24 it will start again from 1
        adder=1

        # put total work hours in an array
        #for time in that is ealier than time out
        if time_IN < time_OUT
            for num in (time_IN+1)...(time_OUT+1)
                if num <=24
                    work.push(num)
                else work.push(adder)
                    adder +=1
                end
                @workHours +=1
            end
    
            #checks how many hours of the hours in work array matches the hours in dayshift array.
            #if they match means that the worker worked at this hour and its dayshift so we count it
            for num in work
                for ber in day_s
                    if num == ber
                        count_d +=1
                    end
                end
            end
        
            #checks how many hours of the hours in work array matches the hours in nightshift array.
            #if they match means that the worker worked at this hour and its nightshift so we count it
            for num in work
                for ber in night_s
                    if num == ber
                        count_n +=1
                    end
                end
            end
    

            @dayshift_hours = count_d-1 #-1 because break time
            @nightshift_hours = count_n
            overTime = (@workHours-1) - 8 #overtime would be the total worktime -8, -1 in workhours because of break.
    
            #if there is overtime
            if overTime >0
                #overtime dayshift is total overtime - the nightshift hours
                @overTime_day = overTime - @nightshift_hours
                #and night overtime will be the nightshift hours (ofcourse, if u work at dayshift and there is night overtime its definitely the hours you work at night)
                @overTime_night = overTime - @overTime_day
            end
    
        #this is if time in is later than time out
        elsif time_IN > time_OUT && time_OUT<13 && time_OUT>0
            #need a different logic, because, if u just do it in reverse, the hours will count from 3 to 18 it includes other numbers that should not be counted
            # for number 24 count down to time in ex: 24 to 18
            for num in (24.downto(time_IN+1))
                #checks if the hour is in dayshift array or night shift array
                if (num <=24)&& ((day_s.include?(num) || night_s.include?(num)))
                    #if yes then worker worked on that hour, and this hour is pushed inside the work array
                    work.push(num)
                end
            end
            adder=1
            #then count from time out down to 1
            for num in ((time_OUT).downto(1))
                #same as above
                if (num <=24)&& (day_s.include?(num) || night_s.include?(num))
                    work.push(num)
                end
            end

            #workhours equals how many elements inside the work array
            @workHours = work.length


            for num in work
                for ber in day_s
                    if num == ber
                        count_d +=1
                    end
                end
            end
        
            for num in work
                for ber in night_s
                    if num == ber
                        count_n +=1
                    end
                end
            end
    
            
            @dayshift_hours = count_d-1
            @nightshift_hours = count_n
            overTime = (@workHours-1) - 8
    
            #if there is overtime then its definitely all night OTs
            if overTime >0
                @overTime_day = 0
                @overTime_night = overTime
            end
        end
    end

   
    #getter and setters
    def get_dayPay()
        return @dayPay
    end

    def get_overtime_day()
        return @overTime_day
    end

    def get_overtime_night()
        return @overTime_night
    end

    def get_hourlyRate()
        return @hourlyRate
    end

    def get_dailySalary()
        return @daily_salary
    end

    def get_timeIn()
        return @timeIN
    end

    def get_timeOut()
        return @timeOUT
    end

    def get_shifInfo()
        return @is_nightShift
    end

    def get_dayType()
        return @dayType
    end

    def get_dayshift()
        return @dayshift_hours
    end

    def get_nightshift()
        return @nightshift_hours
    end

    def set_dailySalary(new_dailySalary = 500)
        @daily_salary = new_dailySalary
    end

    def set_maxWorkHours(new_maxWorkHours = 8)
        @max_workHours = new_maxWorkHours
    end

    def set_timeIn(newtimeIN = 900)
        @timeIN = newtimeIN
    end

    def set_timeOut(newTimeOut = 900)
        @timeOUT = newTimeOut
    end

    def set_shiftInfo(newShift = false)
        @is_nightShift = newShift
    end

    def set_dayType(new_dayType = 0)
        @dayType = new_dayType
        define_dayType(@dayType)
        # puts "Day type set to: #{@dayType}"  #line for debugging
    end

    def set_dayPay(new_dayPay = 0)
        @dayPay = new_dayPay
    end
end




