NORMAL_DAY = 0
REST_DAY = 1
REG_HOLIDAY = 2
SPECIAL_NW = 3
REST_N_NW = 4
REST_N_REGHOLIDAY = 5
DEFAULT_TI = 900
DEFAULT_TO = 900
DEFAULT_DAILY_SALARY = 500
DEFAULT_MAX_WH = 8
require_relative 'workday'


class PayrollSystem
    #initialize system, default workdays = 5/7
    def initialize(num_workdays=5)
        @num_workdays = num_workdays
        @workdays = [7]
        @week_total_daypay = 0
        @total_dayshift = 0
        @total_nightshift = 0
        @total_night_OT = 0
        @total_day_OT = 0

        init_Days()
  
    end

    def init_Days()
        for num in 0...@num_workdays
            @workdays[num] = Workday.new(NORMAL_DAY, DEFAULT_TI, DEFAULT_TO, DEFAULT_DAILY_SALARY, DEFAULT_MAX_WH)
        end
        
        # Initialize rest days for the remaining days in the week
        for num in @num_workdays...7
            @workdays[num] = Workday.new(REST_DAY, DEFAULT_TI, DEFAULT_TO, DEFAULT_DAILY_SALARY, DEFAULT_MAX_WH)
        end
    end

    #main program
    def start_program()
        userchoice = print_main_menu().to_i
        case userchoice
        when 1
            print_allDays()
        when 2
            print_specific_day()
        when 3
            edit_config()
        when 4
            edit_day()
        when 5
            exit
        end
    end

    #prints main menu and gets user input
    def print_main_menu()
        puts "\n\nWeekly Payroll System"
        draw_line()
        puts "enter the number of choice:"
        puts "1. Print all days"
        puts "2. print specific day"
        puts "3. edit system configurations"
        puts "4. edit work day"
        puts "5. exit program"
        puts "enter your choice: "
        userchoice = gets.chomp
        return userchoice.to_i
    end

    #prints all days in a week
    def print_allDays()
        for num in 0...7
            if (@workdays[num].get_dayType==1) && (@workdays[num].get_timeIn == @workdays[num].get_timeOut)
                @workdays[num].set_dayPay(500)
            end
        end

        #displaying the total salary of a worker in a week
        claculate_weekly_salary()
        calculate_total_shift()
        puts "\n\n----------------------------------------"
        puts "total salary for this week: #{@week_total_daypay} pesos"
        puts "total dayshift hours worked : #{@total_dayshift} hours"
        puts "total nightshift hours worked : #{@total_nightshift} hours"
        puts "total dayshift over time: #{@total_day_OT} hours"
        puts "total nightshift over time:#{@total_night_OT} hours"
        puts "----------------------------------------"

        #loop to print from day 1 to day 7
        for num in 0...7
            print_day(num)
        end

        start_program()
    end

    # method for claculating weekly salary
    def claculate_weekly_salary()
        @week_total_daypay = 0
        @workdays.each do |workday|
            @week_total_daypay += workday.get_dayPay
        end
    end

    #method for calculating total dayshift and nightshift hours and OTs paid to worker
    def calculate_total_shift
        @total_dayshift = 0
        @total_nightshift = 0
        @total_day_OT = 0
        @total_night_OT = 0
        @workdays.each do |workday|
            @total_dayshift += workday.get_dayshift
            @total_nightshift += workday.get_nightshift
            @total_day_OT += workday.get_overtime_day
            @total_night_OT += workday.get_overtime_night
        end
    end

    #method for printing a specific day
    def print_specific_day()
        puts "enter day number to print"
        daynum = gets.chomp
        print_day((daynum.to_i)-1)
    end

    #displaying the day info
    def print_day(num)
        puts "\nweekday #{num+1}"
        puts "Daily Rate : #{@workdays[num].get_dailySalary}"
        if @workdays[num].get_timeIn == 2400 
            puts "IN Time: 0000"
            puts "OUT Time: #{sprintf('%04d', @workdays[num].get_timeOut)}"
        elsif @workdays[num].get_timeOut == 2400 
            puts "IN Time: #{sprintf('%04d', @workdays[num].get_timeIn)}"
            puts "OUT Time: 0000"
        else
            puts "IN Time: #{sprintf('%04d', @workdays[num].get_timeIn)}"
            puts "OUT Time: #{sprintf('%04d', @workdays[num].get_timeOut)}"
        end
        puts "day shift work hours : #{@workdays[num].get_dayshift}"
        puts "night shift work hours : #{@workdays[num].get_nightshift}"
        puts "dayshift Overtime : #{@workdays[num].get_overtime_day}"
        puts "nightshift Overtime : #{@workdays[num].get_overtime_night}"
        print_dayType(num)
        puts "salary of the day: #{@workdays[num].get_dayPay}\n"
        draw_line()
    end

    #method to edit the day info
    def edit_day()
        puts "Enter day number to edit:"
        daynum = gets.chomp.to_i - 1
    
        puts "Enter time in (in military time format 0000):"
        newTI = gets.chomp.to_i
        puts "Enter time out (in military time format 0000):"
        newTO = gets.chomp.to_i
        @workdays[daynum].set_timeIn(newTI)
        @workdays[daynum].set_timeOut(newTO)
    
        puts "Enter new day type:"
        puts "[0] Normal day"
        puts "[1] Rest day"
        puts "[2] Regular Holiday"
        puts "[3] Special non-working day"
        puts "[4] Rest day and special non-working day"
        puts "[5] Rest day and regular holiday"
        newDayType = gets.chomp.to_i
        @workdays[daynum].set_dayType(newDayType)
        @workdays[daynum].define_dayType(newDayType)
        @workdays[daynum].calculate_shift_time()
        @workdays[daynum].calculate_Rate()
    
        puts "\nEdit successful"
        puts "New day info:"
        print_day(daynum)
        puts "\n"
        start_program()
    end
    
    

    #method to edit system configurations
    def edit_config()
        userchoice = print_config_menu().to_i
        
        case userchoice
        when 1
            change_workdaynum()
        when 2
            change_max_wh()
        when 3
            change_daily_salary()
        when 4
            start_program()
        end
    end

    #prints the configuration menu and gets user input
    def print_config_menu()
        puts "System configurations"
        puts "1. change workday numbers"
        puts "2. change max work hours per day"
        puts "3. change daily salary"
        puts "4. back"
        userchoice = gets.chomp
        return userchoice.to_i
    end

    #changes the number of workdays in system
    def change_workdaynum()
        puts "enter new number of workdays (1-7):"
        
        new_num_workdays = gets.chomp
        @num_workdays = new_num_workdays.to_i
        init_Days()
        puts "change success"
        edit_config()
    end

    #changes the maximum work hours a day in system
    def change_max_wh()
        puts "enter new max workhours:"
        new_maxWorkHours = gets.chomp
        @workdays.each { |workday| workday.set_maxWorkHours(new_maxWorkHours.to_i) }
        puts "change success"
        edit_config()
    end

    #changes the default daily salary in system
    def change_daily_salary()
        puts "Enter new daily rate:"
        new_daily_salary = gets.chomp
        @workdays.each { |workday| workday.set_dailySalary(new_daily_salary.to_i) }
        puts "Change success"
        edit_config()
      end
      

      #prints the dayType of a specific day
    def print_dayType(num)
        case @workdays[num].get_dayType
        when 0
          puts "day type : Normal day"
        when 1
          puts "day type : Rest day"
        when 2
          puts "day type : Regular Holiday"
        when 3
          puts "day type : Special non working day"
        when 4
          puts "day type : Rest day and Special non working day"
        when 5
          puts "day type : Rest day and Regular Holiday"
        end
      end

      #changes dayType of a specific day
    def change_dayType(daynum)
        puts "enter new daytype:"
        puts "[0] Normal day"
        puts "[1] Rest day"
        puts "[2] Regular Holiday"
        puts "[3] Special non working day"
        puts "[4] Rest day and specia non working day"
        puts "[5] Rest day and regular holiday"
        choice = gets.chomp
        @workdays[daynum-1].set_dayType(choice.to_i)
        puts "change successful\n"
    end

    #just drawing a line
    def draw_line()
        puts "-----------------------------------------------"
    end

end
