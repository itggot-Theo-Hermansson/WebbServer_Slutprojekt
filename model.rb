module MyModule
    # Validates the register form
    # 
    # param [Hash] Data from params
    # @option params [String] Username
    # @option params [String] Password
    def validate_register(params)
        if params["Username"].nil? || params["Password"].nil?
            return false
        else
            return true 
        end
    end

    # Validates edit profile info
    #
    # @param [Hash] Data from params
    # @option params [String] Username Info
    def validate_edit_profile(params)
        if params["Rubrik"].nil?
            return false
        else 
            return true
        end
    end

    # Validates login info
    # 
    # @param [Hash] Data from params
    # @option params [String] Username
    def validate_login(params)
        if params["Username"].nil? || params["Username"].length > 10 || params["Username"].length < 2 || params["Password"].nil? || params["Password"].length < 2 || params["Password"].length > 10
            return false
        else 
            return true
        end
    end
    
    # Database
    def database()
        db = SQLite3::Database.new("db/db_login.db")
        db.results_as_hash = true
        db
    end

    # Login Function
    # 
    # @param [Hash] Data from params
    # @option params [String] Username
    # @option params [String] Password
    # @option params [Integer] Id
    # 
    # @return [Hash], Info from Login
    # 
    def login(params)
        if validate_login(params)
            db = database()
    
            result = db.execute("SELECT * FROM users WHERE Username = ?", params['Username'])
            if result.length > 0
                if BCrypt::Password.new(result[0]["Password"]) == params["Password"]
                    return {
                        login_error: false,
                        user_id: result[0]["Id"],
                        username: params["Username"],
                        user_type: result[0]["User_type"]
                    }
                else
                    return {
                        login_error: true,
                        login_message: "Incorrect Password or Username"
                    }
                end
            else
                return {
                    error_no_info: true,
                    error_no_info_msg: "Incorrect Password or Username"
                }
            end
        else
            return {
                validate_login_error: true,
                validate_login_error_message: "Password needs to be longer than 2 charcters and less than 10"
            }
        end
    end
    
    # Register function
    # 
    # @param [Hash] Data from params
    # @option params [String] Password
    def register(params)
        if validate_register(params)
            db = database()
            new_password = params["Password"] 
            hashed_password = BCrypt::Password.create(new_password)
    
            db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", params["Username"], hashed_password)
        end
    end
    
    # Edit username
    # 
    # @param [Hash] Data from params
    # @option params [String] Password
    def edit_profile(params, user_id)
        if validate_edit_profile(params)
            db = database()
    
            db.execute(%Q(UPDATE users SET Username = '#{params['Rubrik']}' WHERE Id = #{user_id}))
    
            session.destroy
        end
    end
    
    # Log Out function
    # 
    # @param [Hash] Data from params
    def log_out(params)
        session.destroy
    end
    
    # View admin tickets
    # 
    # @param [Hash] Data from params
    # @param [String] Local Variables
    def admin_tickets(params, user_id)
        db = database()
        session['tickets'] = db.execute('SELECT Id, Username, Ticket FROM support_tickets')
    end
    
    # Ticket remove function
    #
    # @param [Hash] Data from params
    def remove_ticket(params)
        db = database()
        db.execute('DELETE FROM support_tickets WHERE Id = ?', params['solve'])
    end
    
    # Moncler product purchase
    #
    # @param [Hash] Data from params
    # @param [String] Local Variables
    def moncler(params, user_id)
        db = database()
        original_price = db.execute('SELECT Pris FROM produkter WHERE Id = 3').first
        user_type = db.execute('SELECT User_type FROM users WHERE Id = ?', user_id).first 
        prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Moncler"')
        if user_type['User_type'] == "Business"
            pris = original_price[0] * 0.8
        else
            pris = original_price[0]
        end
        return {
            product1: prod_name1,
            price: pris
        }
    
    end
    
    # Givenchy product purchase
    #
    # @param [Hash] Data from params
    # @param [String] Local Variables
    def givenchy(params, user_id)
        db = database()
        original_price = db.execute('SELECT Pris FROM produkter WHERE Id = 2').first
        user_type = db.execute('SELECT User_type FROM users WHERE Id = ?', user_id).first
        prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Givenchy"')
        if user_type['User_type'] == "Business"
            pris = original_price[0] * 0.8
        else
            pris = original_price[0]
        end
        return {
            product1: prod_name1,
            price: pris
        }
    end
    
    # Product information
    #
    # @param [Hash] Data from params
    def produkter(params)
        db = database()
        prod_name1 = db.execute('SELECT Kategori FROM produkter WHERE Id = "1" OR "2" OR "3"')
        return prod_name1
    end
    
    # Order history
    #
    # @param [Hash] Data from params
    def bought(params)
        db = database()
        ordrar = db.execute('SELECT * FROM ordrar INNER JOIN users ON ordrar.Id = users.Id')
    
        return {
            orders: ordrar
        }
    end
    
    # Stone-Island product purchase
    #
    # @param [Hash] Data from params
    # @param [String] Local Variables
    def stoneisland(params, user_id)
        db = database()
        original_price = db.execute('SELECT Pris FROM produkter WHERE Id = 1').first
        user_type = db.execute('SELECT User_type FROM users WHERE Id = ?', user_id).first 
        prod_name1 = db.execute('SELECT * FROM produkter WHERE Kategori = "Stone-Island"')
        if user_type['User_type'] == "Business"
            pris = original_price[0] * 0.8
        else
            pris = original_price[0]
        end
        return {
            product1: prod_name1,
            price: pris
        }
    end
    
    # Purchase function
    #
    # @param [Hash] Data from params
    # @param [String] Local Variables
    def buy(params, product)
        db = database()
        amount = db.execute('SELECT Amount FROM produkter WHERE Id = ?', params['buy']).first
        product = db.execute('SELECT Produkt_Namn FROM produkter WHERE Id = ?', params['buy']).first
        antal_kvar = amount[0] - 1
        db.execute('UPDATE produkter SET Amount = ? WHERE Id = ?', antal_kvar, params['buy'])
        db.execute('INSERT INTO ordrar (Id) VALUES (?)', params['buy'])
    end
    
    # Ticket creater
    #
    # @param [Hash] Data from params
    # @param [String] Local Variables
    def kundsupport(params, user_id, username)
        db = database()
        db.execute("INSERT INTO support_tickets (Id, Username, Ticket) VALUES (?, ?, ?)", user_id, username, params["Help"])
    end
end
