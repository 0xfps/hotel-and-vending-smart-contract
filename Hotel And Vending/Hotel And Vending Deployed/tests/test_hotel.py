from brownie import HAV, accounts, network, config, reverts

def getAccount():
   ## Choose an account.
   account = accounts[0]

   return account



def deploy():
   
   acc = getAccount()

   print("Deploying contract...")

   ## Deploy.
   deployed_contract = HAV.deploy({"from":acc})

   return deployed_contract



def testBook():

   acc = getAccount()

   dep = deploy()

   dep.book("password", {"from":acc, "value": "50000 gwei"})

   expected = dep.viewOwner(acc)

   ## The owner of the room should be the owner
   assert expected == acc


def testBookFor():

   acc = getAccount()
   acc2 = accounts[1]

   dep = deploy()

   dep.bookFor(acc2, "password", {"from":acc, "value": "50000 gwei"})

   expected = dep.viewOwner(acc2)

   ## The owner of the room should be the owner
   assert expected != acc
   assert expected == acc2



def testLeave():
   acc = getAccount()
   acc2 = accounts[1]
   acc3 = accounts[2]

   dep = deploy()

   dep.book("password", {"from":acc, "value": "50000 gwei"})
   dep.approve(acc2, {"from": acc})
   dep.approve(acc3, {"from": acc})
   dep.revoke(acc2, {"from": acc})
   dep.leave(acc, {"from": acc})

   _zero = "0x0000000000000000000000000000000000000000"
   expected = "0x0000000000000000000000000000000000000000"
   

   with reverts():
      expected = dep.viewOwner(acc)

   ## The owner of the room should be the owner
   assert expected == _zero