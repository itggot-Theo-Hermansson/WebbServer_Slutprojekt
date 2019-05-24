require 'sinatra'
require 'slim'
require 'sqlite3'
require 'byebug'
require 'bcrypt'
require_relative 'model'

enable :sessions

include MyModule

helpers do
    def get_error()
        message = session[:msg_login_failed].dup
        session[:msg_login_failed] = nil
        return message
    end
    def get_validate_error()
        message = session[:validate_login_error_message].dup
        session[:validate_login_error_message] = nil
        return message
    end
    def username_validate()
        message = session[:error_no_info_message].dup
        session[:error_no_info_message] = nil
        return message
    end

    def admin?
        session[:user_type] == "Admin"
    end
end


# Display Landing Page
#
get('/') do
    if session[:username] != nil
        redirect('/produkter')
    end
    slim(:home)
end

# Display Login Page
#
get('/login') do
    if session[:username] != nil
        redirect('/produkter')
    end
    slim(:login)
end

# Display Admin Page
#
get('/admin') do
    if session[:username] == nil
        redirect('/login')
    end 
    if admin? 
        slim(:admin)
    else
        redirect('/produkter')
    end

end


# Dissplay Admin Ticket Page
#
get('/admin/help') do
    if session[:username] == nil
        redirect('/login')
    end
    admin?
    admin_tickets(params, session["user_id"])
    slim(:admin_help)
    redirect('/admin/help')
end

# Removes Tickets
#
post('/admin/help') do
    remove_ticket(params)
end

# Displays Orders
#
get('/admin/beställt') do
    if session[:username] == nil
        redirect('/login')
    end
    bought_result = bought(params)
    slim(:beställt, locals:{
        result: bought_result
    })
end

# Performs the login 
#
post('/login') do
    result = login(params)

    if result[:validate_login_error]
        session[:validate_login_error_message] = result[:validate_login_error_message]
        redirect back 
    elsif result[:login_error]
        session[:msg_login_failed] = result[:login_message]
        redirect back
    elsif result[:error_no_info]
        session[:error_no_info_message] = result[:error_no_info_msg]
        redirect back
    else
        session[:user_type] = result[:user_type]
        session[:user_id] = result[:user_id]
        session[:username] = result[:username]
        redirect("/produkter")
    end
end

# Display Register
#
get('/register') do
    if session[:username] != nil
        redirect('/produkter')
    end
    slim(:register)
end

# Performs the login
#
post('/register') do
    register(params)
end

# Display login failed page
#
get('/failed') do
    slim(:failed)
end

# Display search page
#
get('/search') do
    slim(:search)
end

# Performs the search
#
post('/search') do
    search(params)
    redirect('/search')
end

# Display profile page
#
get('/profil') do
    if session[:username] == nil
        redirect('/login')
    end
    slim(:profil)
end

# Performs the logout
#
post('/profil') do
    log_out(params)
    redirect('/')
end

# Display the edit profile page
#
# @param [Integer] :id, The Id of the user
#
get('/edit_profile/:id') do
    slim(:edit_profile)
end

# Edits the username
#
post('/edit_profile') do
    edit_profile(params, session["user_id"])
end

# Display Moncler Products
#
get('/produkter/moncler') do
    if session[:username] == nil
        redirect('/login')
    end
    moncler_info = moncler(params, session['user_id'])
    slim(:moncler, locals:{
        result: moncler_info
    })
end

# Performs the purchase
#
post('/produkter/moncler') do
    buy(params, session["product"])
end

# Displays main product page
#
get('/produkter') do
    result = produkter(params)
    slim(:produkter, locals:{
        result: result
    })
end

# Purchase of products
#
post('/produkter') do
    buy(params, session["product"])
end

# Display Stonge-Island products
#
get('/produkter/Stone-Island') do
    if session[:username] == nil
        redirect('/login')
    end
    stoneisland_info = stoneisland(params, session['user_id'])
    slim(:stoneisland, locals:{
        result: stoneisland_info
    })
end

# Performs the purchase of a Stone-Island Product
#
post('/produkter/Stone-Island') do
    buy(params, session["product"])
end

# Displays the Givenchy products
#
get('/produkter/Givenchy') do
    if session[:username] == nil
        redirect('/login')
    end
    givenchy_info = givenchy(params, session['user_id'])
    slim(:givenchy, locals:{
        result: givenchy_info
    })
end

# Performs the purchase of a Givenchy Product
#
post('/produkter/Givenchy') do
    buy(params, session["product"])
end

# Displays the help page
#
get('/help') do
    if session[:username] == nil
        redirect('/login')
    end
    slim(:kundsupport)
end

# Send the ticket
#
post('/help') do
    kundsupport(params, session["user_id"], session["username"])
end