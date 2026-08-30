def get_user_input(cargo):
    if "session" not in cargo:
        # opening message
        cargo["user_input"] = input("Tell me about the system you want to build ")
    else:
        # user is dissatisfied with the current, valid Alloy result
        user_input = input("Can you be more precise, or try again? (/quit to stop) ")
        if user_input.lower() == "/quit":
            return ("done", cargo)
        cargo["user_input"] = user_input

    cargo.pop("explain", None)
    cargo.pop("prior_error", None)
    return ("agent", cargo)


def get_user_confirmation(cargo):
    # TODO: present as grpahical/HTML buttons inside Gradio
    reply = input("Does this look correct? (y/n/idk) ")
    match reply.lower():
        case "y":
            return ("log_version", cargo)
        case "n":
            return ("user_input", cargo)
        case _:
            # "I Don't Know" case: ask the Alloy bot to explain its thinking
            cargo["explain"] = "Can you explain your prior response in more detail?"
            return ("agent", cargo)
