def get_user_input(cargo):
    if "session" not in cargo:
        # opening message
        cargo["user_input"] = input("Tell me about the system you want to build ")
    else:
        user_input = input("Can you be more precise, or try again? (/quit to stop) ")
        if user_input.lower() == "/quit":
            return ("done", cargo)
        cargo["user_input"] = user_input
    return ("agent", cargo)


def get_user_confirmation(cargo):
    reply = input("Does this look correct? (y/n/idk) ")
    match reply.lower():
        case "y":
            return ("log_version", cargo)
        case "n":
            return ("user_input", cargo)
        case _:
            return ("agent", cargo)
