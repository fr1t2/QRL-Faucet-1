const explorerHelpers = require("@theqrl/explorer-helpers")

const args = process.argv.slice(2);
console.log('args: ', args);


async function main(){
        const address = args[0];

        const bytes = await explorerHelpers.hexAddressToRawAddress(address);
        console.log(JSON.stringify(bytes));

        const b32Address = await explorerHelpers.hexAddressToB32Address(address);
        console.log(JSON.stringify(b32Address));

        const b32bytes = await explorerHelpers.b32AddressToRawAddress(b32Address);
        console.log(JSON.stringify(b32bytes));

};

main();
